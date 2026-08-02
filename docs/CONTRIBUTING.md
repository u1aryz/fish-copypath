# Contributing to fish-copypath

Thank you for helping improve fish-copypath. Contributions from people of every background and experience level are welcome.

By participating, you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md). Please report security problems through the process described in the [Security Policy](SECURITY.md), not in a public issue.

## Requirements

- Fish 3.5 or later
- Git
- Fisher, when testing plugin installation locally

## Development

Fork and clone the repository, then create a focused branch for your change.

Run all checks before opening a pull request:

```fish
fish --no-config --no-execute functions/*.fish completions/*.fish tests/*.fish
fish_indent --check functions/*.fish completions/*.fish tests/*.fish
fish --no-config tests/test_copypath.fish
```

Keep user-facing text, documentation, code comments, tests, and commit messages in English. Add or update tests whenever behavior changes.

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/) in English. Keep each commit focused and ensure it passes the relevant checks.

Examples:

```text
feat: add support for a clipboard backend
fix: preserve paths containing newlines
docs: clarify installation requirements
```

## Pull requests

- Explain the problem and the proposed solution.
- Keep the change as small as practical.
- Include tests for new or corrected behavior.
- Update documentation when users will notice the change.
- Confirm that syntax, formatting, and test checks pass.

Maintainers may ask for changes before merging. Review feedback should be addressed with the same respectful and constructive tone expected elsewhere in the project.
