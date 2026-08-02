function copypath --description 'Copy an absolute path to the clipboard'
    if test (count $argv) -gt 1
        printf 'copypath: expected at most one path\n' >&2
        printf 'Usage: copypath [PATH]\n' >&2
        return 2
    end

    set -l input_path .
    if test (count $argv) -eq 1; and test -n "$argv[1]"
        set input_path $argv[1]
    end

    if not string match --quiet -- '/*' "$input_path"
        set input_path "$PWD/$input_path"
    end

    set -l absolute_path (path normalize --null-out -- "$input_path" | string split0)
    if test (count $absolute_path) -ne 1
        printf 'copypath: failed to normalize path: %s\n' "$input_path" >&2
        return 1
    end

    __copypath_copy "$absolute_path"
    set -l copy_status $status
    if test $copy_status -ne 0
        return $copy_status
    end

    printf '%s copied to clipboard.\n' "$absolute_path"
end
