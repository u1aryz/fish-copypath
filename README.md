# fish-copypath

[![CI](https://github.com/u1aryz/fish-copypath/actions/workflows/ci.yml/badge.svg)](https://github.com/u1aryz/fish-copypath/actions/workflows/ci.yml)
[![Fish Shell](https://img.shields.io/badge/fish-3.5%2B-4AAE47?logo=fishshell&logoColor=white)](https://fishshell.com/)
[![Fisher](https://img.shields.io/badge/Fisher-compatible-00A4CC)](https://github.com/jorgebucaran/fisher)
[![License](https://img.shields.io/github/license/u1aryz/fish-copypath)](LICENSE)

Copy the absolute path of a file or directory to the system clipboard from Fish.

## Installation

fish-copypath requires Fish 3.5 or later and [Fisher](https://github.com/jorgebucaran/fisher).

```fish
fisher install u1aryz/fish-copypath
```

## Usage

Copy the current directory:

```console
$ copypath
Copied: /home/user/project
```

Copy a file or directory path:

```console
$ copypath ./README.md
Copied: /home/user/project/README.md
```

Relative paths are converted to absolute paths without resolving symbolic links. File and directory completion is available for the path argument.

## Clipboard support

fish-copypath automatically uses the first available backend:

- macOS: `pbcopy`
- Cygwin or MSYS: `/dev/clipboard`
- Windows or WSL: `clip.exe`
- Wayland: `wl-copy`
- X11: `xsel` or `xclip`
- Remote and alternative environments: `lemonade`, `doitclient`, `win32yank`, `termux-clipboard-set`, or `tmux`

## Acknowledgments

Inspired by the [`copypath.plugin.zsh`](https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/copypath/copypath.plugin.zsh) plugin from [Oh My Zsh](https://ohmyz.sh/).

## License

[MIT](LICENSE)
