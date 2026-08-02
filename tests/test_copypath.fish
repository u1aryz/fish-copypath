#!/usr/bin/env fish

set -g test_project_root (path resolve (path dirname (status filename))/..)
set -g test_original_path $PATH
set -g test_mktemp (command --search mktemp)
set -g test_mkdir (command --search mkdir)
set -g test_chmod (command --search chmod)
set -g test_cmp (command --search cmp)
set -g test_rm (command --search rm)
set -g test_ln (command --search ln)
set -g test_temp ($test_mktemp -d)
set -g test_failures 0
set -g test_passes 0

source $test_project_root/functions/__copypath_copy.fish
source $test_project_root/functions/copypath.fish

function test_pass --argument-names description
    set -g test_passes (math $test_passes + 1)
    printf 'ok - %s\n' "$description"
end

function test_fail --argument-names description details
    set -g test_failures (math $test_failures + 1)
    printf 'not ok - %s\n' "$description" >&2
    if test -n "$details"
        printf '  %s\n' "$details" >&2
    end
end

function assert_equal --argument-names description expected actual
    if test "$actual" = "$expected"
        test_pass "$description"
    else
        test_fail "$description" "expected "(string escape -- "$expected")", got "(string escape -- "$actual")
    end
end

function assert_file_equal --argument-names description expected actual
    if $test_cmp --silent -- "$expected" "$actual"
        test_pass "$description"
    else
        test_fail "$description" "files differ: $expected and $actual"
    end
end

function make_mock_backend --argument-names backend bin_dir
    set -l executable "$bin_dir/$backend"
    printf '%s\n' \
        '#!/bin/sh' \
        'printf "%s" "${0##*/}" > "$COPYPATH_TEST_SELECTED"' \
        ': > "$COPYPATH_TEST_ARGS"' \
        'for argument in "$@"; do' \
        '    printf "%s\n" "$argument" >> "$COPYPATH_TEST_ARGS"' \
        done \
        '/bin/cat > "$COPYPATH_TEST_CONTENT"' \
        'exit "${COPYPATH_TEST_EXIT:-0}"' >$executable
    $test_chmod +x $executable
end

function reset_display_environment
    set --erase WAYLAND_DISPLAY
    set --erase DISPLAY
    set --erase TMUX
end

function prepare_case --argument-names backend
    set -l case_dir ($test_mktemp -d "$test_temp/case.XXXXXX")
    set -l bin_dir "$case_dir/bin"
    $test_mkdir -p $bin_dir
    make_mock_backend $backend $bin_dir

    set -gx COPYPATH_TEST_SELECTED "$case_dir/selected"
    set -gx COPYPATH_TEST_ARGS "$case_dir/args"
    set -gx COPYPATH_TEST_CONTENT "$case_dir/content"
    set -gx COPYPATH_TEST_EXIT 0
    set -gx PATH $bin_dir
    reset_display_environment

    printf '%s\n' $case_dir
end

function run_backend_case
    set -l backend $argv[1]
    set -l expected_arguments $argv[2..-1]
    set -l case_dir (prepare_case $backend)

    switch $backend
        case wl-copy
            set -gx WAYLAND_DISPLAY wayland-0
        case xsel xclip
            set -gx DISPLAY :99
        case tmux
            set -gx TMUX mock-tmux
    end

    set -l target "$test_temp/backend target"
    copypath "$target" >"$case_dir/stdout" 2>"$case_dir/stderr"
    set -l command_status $status
    set -gx PATH $test_original_path

    assert_equal "$backend returns success" 0 $command_status
    set -l selected (string collect <"$case_dir/selected")
    assert_equal "$backend is selected" $backend "$selected"

    printf '' >"$case_dir/expected-args"
    for expected_argument in $expected_arguments
        printf '%s\n' "$expected_argument" >>"$case_dir/expected-args"
    end
    assert_file_equal "$backend receives the expected arguments" "$case_dir/expected-args" "$case_dir/args"

    printf '%s' "$target" >"$case_dir/expected-content"
    assert_file_equal "$backend receives the path without a trailing newline" "$case_dir/expected-content" "$case_dir/content"
    printf '%s copied to clipboard.\n' "$target" >"$case_dir/expected-stdout"
    assert_file_equal "$backend produces the success message" "$case_dir/expected-stdout" "$case_dir/stdout"
    printf '' >"$case_dir/expected-stderr"
    assert_file_equal "$backend does not produce an error" "$case_dir/expected-stderr" "$case_dir/stderr"
end

function check_successful_path
    set -l description $argv[1]
    set -l expected_path $argv[2]
    set -l supplied_arguments $argv[3..-1]
    set -l case_dir ($test_mktemp -d "$test_temp/path.XXXXXX")

    set -gx COPYPATH_TEST_SELECTED "$case_dir/selected"
    set -gx COPYPATH_TEST_ARGS "$case_dir/args"
    set -gx COPYPATH_TEST_CONTENT "$case_dir/content"
    set -gx COPYPATH_TEST_EXIT 0

    copypath $supplied_arguments >"$case_dir/stdout" 2>"$case_dir/stderr"
    set -l command_status $status
    assert_equal "$description returns success" 0 $command_status

    printf '%s' "$expected_path" >"$case_dir/expected-content"
    assert_file_equal "$description copies the expected path" "$case_dir/expected-content" "$case_dir/content"
    printf '%s copied to clipboard.\n' "$expected_path" >"$case_dir/expected-stdout"
    assert_file_equal "$description prints the expected path" "$case_dir/expected-stdout" "$case_dir/stdout"
end

for backend_case in \
    pbcopy \
    'clip.exe' \
    wl-copy \
    'xsel|--clipboard|--input' \
    'xclip|-selection|clipboard|-in' \
    'lemonade|copy' \
    'doitclient|wclip' \
    'win32yank|-i' \
    termux-clipboard-set \
    'tmux|load-buffer|-w|-'
    set -l backend_parts (string split '|' -- $backend_case)
    run_backend_case $backend_parts
end

set -l priority_dir ($test_mktemp -d "$test_temp/priority.XXXXXX")
set -l priority_bin "$priority_dir/bin"
$test_mkdir -p $priority_bin
for backend in pbcopy clip.exe wl-copy xsel xclip lemonade doitclient win32yank termux-clipboard-set tmux
    make_mock_backend $backend $priority_bin
end
set -gx COPYPATH_TEST_SELECTED "$priority_dir/selected"
set -gx COPYPATH_TEST_ARGS "$priority_dir/args"
set -gx COPYPATH_TEST_CONTENT "$priority_dir/content"
set -gx COPYPATH_TEST_EXIT 0
set -gx WAYLAND_DISPLAY wayland-0
set -gx DISPLAY :99
set -gx TMUX mock-tmux
set -gx PATH $priority_bin
copypath "$test_temp/priority" >"$priority_dir/stdout" 2>"$priority_dir/stderr"
set -l priority_status $status
set -gx PATH $test_original_path
assert_equal 'backend priority returns success' 0 $priority_status
assert_equal 'pbcopy has the highest backend priority' pbcopy (string collect <"$priority_dir/selected")

set -l path_dir (prepare_case pbcopy)
set -l work_dir "$test_temp/work"
$test_mkdir -p "$work_dir/actual"
$test_ln -s actual "$work_dir/link"
cd $work_dir

check_successful_path 'omitted path' "$work_dir"
check_successful_path 'empty path' "$work_dir" ''
check_successful_path 'relative path' "$work_dir/missing file" 'directory/../missing file'
check_successful_path 'absolute path' "$work_dir/absolute" "$work_dir/absolute"
check_successful_path 'leading hyphen path' "$work_dir/-draft" -draft
set -l unicode_path (string unescape 'fish-\U0001F41F')
check_successful_path 'Unicode path' "$work_dir/$unicode_path" "$unicode_path"
check_successful_path 'symbolic-link path' "$work_dir/link/file" 'link/./file'
set -l newline_path "line
break"
check_successful_path 'newline path' "$work_dir/$newline_path" "$newline_path"

set -l arguments_dir ($test_mktemp -d "$test_temp/arguments.XXXXXX")
set -gx COPYPATH_TEST_SELECTED "$arguments_dir/selected"
set -gx COPYPATH_TEST_ARGS "$arguments_dir/args"
set -gx COPYPATH_TEST_CONTENT "$arguments_dir/content"
printf marker >"$arguments_dir/content"
copypath one two >"$arguments_dir/stdout" 2>"$arguments_dir/stderr"
set -l arguments_status $status
assert_equal 'multiple paths return a usage error' 2 $arguments_status
printf '' >"$arguments_dir/expected-stdout"
assert_file_equal 'multiple paths do not print a success message' "$arguments_dir/expected-stdout" "$arguments_dir/stdout"
printf '%s\n' 'copypath: expected at most one path' 'Usage: copypath [PATH]' >"$arguments_dir/expected-stderr"
assert_file_equal 'multiple paths print English usage guidance' "$arguments_dir/expected-stderr" "$arguments_dir/stderr"
printf marker >"$arguments_dir/expected-content"
assert_file_equal 'multiple paths do not modify the clipboard' "$arguments_dir/expected-content" "$arguments_dir/content"

set -l failure_dir (prepare_case pbcopy)
set -gx COPYPATH_TEST_EXIT 23
copypath "$work_dir/failure" >"$failure_dir/stdout" 2>"$failure_dir/stderr"
set -l failure_status $status
set -gx PATH $test_original_path
assert_equal 'backend failure status is preserved' 23 $failure_status
printf '' >"$failure_dir/expected-stdout"
assert_file_equal 'backend failure does not print a success message' "$failure_dir/expected-stdout" "$failure_dir/stdout"
printf '%s\n' 'copypath: failed to copy path using pbcopy' >"$failure_dir/expected-stderr"
assert_file_equal 'backend failure names the selected backend' "$failure_dir/expected-stderr" "$failure_dir/stderr"

set -l missing_dir ($test_mktemp -d "$test_temp/missing.XXXXXX")
set -l empty_bin "$missing_dir/bin"
$test_mkdir -p $empty_bin
reset_display_environment
set -gx PATH $empty_bin
copypath "$work_dir/missing-backend" >"$missing_dir/stdout" 2>"$missing_dir/stderr"
set -l missing_status $status
set -gx PATH $test_original_path
assert_equal 'missing backend returns failure' 1 $missing_status
printf '' >"$missing_dir/expected-stdout"
assert_file_equal 'missing backend does not print a success message' "$missing_dir/expected-stdout" "$missing_dir/stdout"
printf '%s\n' 'copypath: no supported clipboard tool found (pbcopy, clip.exe, wl-copy, xsel, xclip, lemonade, doitclient, win32yank, termux-clipboard-set, or tmux)' >"$missing_dir/expected-stderr"
assert_file_equal 'missing backend lists supported tools in English' "$missing_dir/expected-stderr" "$missing_dir/stderr"

complete --erase --command copypath
source $test_project_root/completions/copypath.fish
printf '' >"$work_dir/alpha.txt"
set -l first_argument_completions (complete --do-complete 'copypath al')
assert_equal 'first argument completes paths' alpha.txt "$first_argument_completions"
set -l extra_argument_completions (complete --do-complete 'copypath alpha.txt ')
assert_equal 'completion stops after the first path' 0 (count $extra_argument_completions)

cd $test_project_root
set -gx PATH $test_original_path
$test_rm -rf -- $test_temp

printf '\n%d tests passed, %d tests failed\n' $test_passes $test_failures
if test $test_failures -ne 0
    exit 1
end
