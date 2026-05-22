# Contributing to GoToBed

Thanks for your interest in improving GoToBed! This is a small, focused macOS
menu-bar app, and contributions of all sizes are welcome.

## Development setup

Requirements: macOS 13+, Xcode 16 / Swift 6 toolchain.

```sh
make build      # swift build
make test       # swift test
make validate   # build + test + no-network check (the gate CI runs)
make app        # build a universal GoToBed.app into build/
```

Please run `make validate` before opening a PR — it must pass.

## Architecture

A SwiftPM package with two targets:

- **`GoToBedCore`** — pure, framework-agnostic logic (model, validation,
  schedule math, persistence, contrast). **Fully unit-tested.** New logic
  belongs here, with tests in `Tests/GoToBedCoreTests`.
- **`GoToBed`** — the menu-bar app: AppKit/SwiftUI glue (scheduler, overlay
  window, settings UI). Keep correctness-critical logic in the core so it stays
  testable.

See [`README.md`](README.md) for more, and [`PRD.md`](PRD.md) for the product
spec.

## Commit messages — Conventional Commits

Releases are automated with [release-please](https://github.com/googleapis/release-please),
which **derives the version and changelog from commit messages**, so please use
[Conventional Commits](https://www.conventionalcommits.org):

| Prefix | Effect | Example |
|--------|--------|---------|
| `fix:` | patch release | `fix: keep app alive when settings closes` |
| `feat:` | minor release | `feat: add weekly snooze` |
| `feat!:` / `BREAKING CHANGE:` | major release | `feat!: drop macOS 13 support` |
| `docs:` `chore:` `ci:` `refactor:` `test:` | no release | `docs: clarify install steps` |

## Pull requests

1. Fork and branch from `main`.
2. Make your change with a test where it's logic that can be tested.
3. Ensure `make validate` passes.
4. Use a Conventional Commit style title and fill out the PR template.

Maintainers cut releases by merging the automated "release" PR — you don't need
to bump versions or tag.

## Privacy invariant

GoToBed is **fully offline**: no networking APIs, no telemetry, no network
entitlement. `scripts/verify-no-network.sh` enforces this in CI — changes that
introduce network access will fail the gate.

## Code of Conduct

By participating you agree to the [Code of Conduct](CODE_OF_CONDUCT.md).
