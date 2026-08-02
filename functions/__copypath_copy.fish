function __copypath_copy --description 'Copy text with an available clipboard backend'
    if test (count $argv) -ne 1
        printf 'copypath: internal clipboard helper expected one value\n' >&2
        return 2
    end

    set -l backend
    set -l copy_command

    if command --search --quiet pbcopy
        set backend pbcopy
        set copy_command pbcopy
    else if test -w /dev/clipboard
        set backend /dev/clipboard
    else if command --search --quiet clip.exe
        set backend clip.exe
        set copy_command clip.exe
    else if set --query WAYLAND_DISPLAY; and test -n "$WAYLAND_DISPLAY"; and command --search --quiet wl-copy
        set backend wl-copy
        set copy_command wl-copy
    else if set --query DISPLAY; and test -n "$DISPLAY"; and command --search --quiet xsel
        set backend xsel
        set copy_command xsel --clipboard --input
    else if set --query DISPLAY; and test -n "$DISPLAY"; and command --search --quiet xclip
        set backend xclip
        set copy_command xclip -selection clipboard -in
    else if command --search --quiet lemonade
        set backend lemonade
        set copy_command lemonade copy
    else if command --search --quiet doitclient
        set backend doitclient
        set copy_command doitclient wclip
    else if command --search --quiet win32yank
        set backend win32yank
        set copy_command win32yank -i
    else if command --search --quiet termux-clipboard-set
        set backend termux-clipboard-set
        set copy_command termux-clipboard-set
    else if set --query TMUX; and test -n "$TMUX"; and command --search --quiet tmux
        set backend tmux
        set copy_command tmux load-buffer -w -
    else
        printf '%s\n' 'copypath: no supported clipboard tool found (pbcopy, clip.exe, wl-copy, xsel, xclip, lemonade, doitclient, win32yank, termux-clipboard-set, or tmux)' >&2
        return 1
    end

    if test "$backend" = /dev/clipboard
        printf '%s' "$argv[1]" >/dev/clipboard
    else
        printf '%s' "$argv[1]" | command $copy_command
    end

    set -l copy_status $status
    if test $copy_status -ne 0
        printf 'copypath: failed to copy path using %s\n' "$backend" >&2
        return $copy_status
    end
end
