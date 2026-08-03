# fish-copypath

[![CI](https://github.com/u1aryz/fish-copypath/actions/workflows/ci.yml/badge.svg)](https://github.com/u1aryz/fish-copypath/actions/workflows/ci.yml)
[![GitHub Release](https://img.shields.io/github/v/release/u1aryz/fish-copypath)](https://github.com/u1aryz/fish-copypath/releases/latest)
[![Fish Shell](https://img.shields.io/badge/fish-3.5%2B-4AAE47?logo=fishshell&logoColor=white)](https://fishshell.com/)
[![Fisher](https://img.shields.io/badge/Fisher-compatible-00A4CC)](https://github.com/jorgebucaran/fisher)
[![License](https://img.shields.io/github/license/u1aryz/fish-copypath)](LICENSE)

A cross-platform Fish shell plugin that copies absolute file and directory paths to the system clipboard.

<img src="docs/assets/demo.gif" alt="fish-copypath demo" width="640">

## Why fish-copypath?

Use `copypath` when you want to paste a path into an editor, issue, chat, or another terminal without typing it by hand. It provides the familiar [`copypath`](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/copypath) workflow from Oh My Zsh, built for Fish with path completion and cross-platform clipboard support.

## Installation

fish-copypath requires Fish 3.5 or later and [Fisher](https://github.com/jorgebucaran/fisher).

```fish
fisher install u1aryz/fish-copypath
```

To install a specific release:

```fish
fisher install u1aryz/fish-copypath@v1.0.0
```

To uninstall:

```fish
fisher remove u1aryz/fish-copypath
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

| Environment | Clipboard backend |
| --- | --- |
| macOS | `pbcopy` |
| Cygwin or MSYS | `/dev/clipboard` |
| Windows or WSL | `clip.exe` |
| Wayland | `wl-copy` |
| X11 | `xsel` or `xclip` |
| Remote and alternative environments | `lemonade`, `doitclient`, `win32yank`, `termux-clipboard-set`, or `tmux` |

## Acknowledgments

Inspired by the [`copypath.plugin.zsh`](https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/copypath/copypath.plugin.zsh) plugin from [Oh My Zsh](https://ohmyz.sh/).

## License

[MIT](LICENSE)
