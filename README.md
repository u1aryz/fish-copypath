# fish-copypath

[![CI](https://github.com/u1aryz/fish-copypath/actions/workflows/ci.yml/badge.svg)](https://github.com/u1aryz/fish-copypath/actions/workflows/ci.yml)
[![Fish Shell](https://img.shields.io/badge/fish-3.5%2B-4AAE47?logo=fishshell&logoColor=white)](https://fishshell.com/)
[![Fisher](https://img.shields.io/badge/Fisher-compatible-00A4CC)](https://github.com/jorgebucaran/fisher)
[![License](https://img.shields.io/github/license/u1aryz/fish-copypath)](LICENSE)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-FE5196?logo=conventionalcommits&logoColor=white)](https://www.conventionalcommits.org/)
[![GitHub stars](https://img.shields.io/github/stars/u1aryz/fish-copypath)](https://github.com/u1aryz/fish-copypath/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/u1aryz/fish-copypath)](https://github.com/u1aryz/fish-copypath/forks)
[![GitHub issues](https://img.shields.io/github/issues/u1aryz/fish-copypath)](https://github.com/u1aryz/fish-copypath/issues)
[![GitHub last commit](https://img.shields.io/github/last-commit/u1aryz/fish-copypath)](https://github.com/u1aryz/fish-copypath/commits/main)

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
/home/user/project copied to clipboard.
```

Copy a file or directory path:

```console
$ copypath ./README.md
/home/user/project/README.md copied to clipboard.
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
