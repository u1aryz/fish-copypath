# Repository Guidelines

- This repository contains a Fish shell plugin. Support Fish 3.5 and later.
- Keep changes small, portable, and consistent with the existing Fish style.
- Run these checks before finishing:

```fish
fish --no-config --no-execute functions/*.fish completions/*.fish tests/*.fish
fish_indent --check functions/*.fish completions/*.fish tests/*.fish
fish --no-config tests/test_copypath.fish
```

- Use [Conventional Commits](https://www.conventionalcommits.org/) for commit messages, such as `feat: add a clipboard backend` or `fix: preserve symbolic links`.
