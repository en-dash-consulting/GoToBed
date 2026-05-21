# GoToBed

A lightweight macOS menu-bar app that draws a full-screen overlay (like a
screensaver) at user-scheduled times — a hard-to-ignore but non-destructive
nudge to stop and go to bed. Schedules and messages are fully user-defined and
work equally well for breaks or end-of-day reminders.

See [`PRD.md`](PRD.md) for the full product spec.

## Install

1. Download the latest `GoToBed-x.y.z.dmg` from the [releases page](https://github.com/en-dash-consulting/GoToBed/releases/latest) (or [gotobed.endash.us](https://gotobed.endash.us)).
2. Open the DMG and drag **GoToBed** into **Applications**.
3. Launch it — look for the moon icon in your menu bar (there is no Dock icon).

Universal (Apple Silicon + Intel), macOS 13+. Builds are Developer ID signed and
notarized, so they launch without a Gatekeeper prompt.

## Updating

GoToBed is fully offline and does not phone home, so updates are manual:

1. Menu-bar icon → **Check for Updates…** (opens the releases page in your browser).
2. Download the newer DMG and drag **GoToBed** into **Applications**, replacing the old copy.
3. Relaunch.

## Requirements

- macOS 13 (Ventura) or later
- Xcode 16 / Swift 6 toolchain (builds in Swift 5 language mode)

## Build, test, run

```sh
make build      # swift build
make test       # swift test (40 unit tests)
make validate   # build + test + no-network check (the project validation gate)
make app        # build a signed universal GoToBed.app into build/
```

`make app` produces `build/GoToBed.app` as a universal (arm64 + x86_64) bundle,
ad-hoc signed by default. Pass a Developer ID to sign for distribution:
`./scripts/build-app.sh "Developer ID Application: …"`.

## Architecture

A SwiftPM package with two targets:

| Target | Role |
|--------|------|
| `GoToBedCore` | Pure, framework-agnostic logic: `Schedule`/`AppState` model, validation, `ScheduleCalculator` (next-fire math), `AppStatePersistence`, `Store`, contrast, `os_log`. Fully unit-tested. |
| `GoToBed` | The menu-bar app: `SchedulerEngine` (timer + wake/clock observers), `OverlayController`/`OverlayWindow` (the soft overlay), and the SwiftUI settings/editor UI. |

The split keeps all correctness-critical logic testable without a running app or
UI. The app target is thin AppKit/SwiftUI glue over the core.

### Key design decisions

- **Skip, never replay (NFR-rel-2).** `ScheduleCalculator` only ever computes
  occurrences *strictly after* a reference instant. On wake the scheduler
  recomputes from "now", so a time that elapsed during sleep is simply never
  produced — no special-case replay logic. Same property gives FR-4.
- **Single coalesced timer (§5.5).** One `Timer` is armed to the soonest fire
  across all schedules and re-armed on every fire, store change, wake, and
  clock/timezone change. Re-arming invalidates the previous timer, so timers
  cannot accumulate (addresses the soak/leak concern by construction).
- **Soft overlay (FR-8).** A borderless `NSWindow` at `CGShieldingWindowLevel`
  covers the menu bar and Dock across spaces, but never captures the event tap
  or hides the menu bar globally — `Esc`, `Cmd-Tab`, Mission Control, and
  force-quit always work.
- **Menu-bar only (FR-18).** Runs with `.accessory` activation policy (and
  `LSUIElement` in the bundle), so there is no Dock icon. The overlay briefly
  flips to `.regular` to take key focus for `Esc`, then restores `.accessory`.
- **Offline (NFR-priv-1).** No networking APIs anywhere; the entitlements grant
  no network capability. Enforced by `scripts/verify-no-network.sh`.

## Acceptance criteria coverage

The §7 criteria with headless-testable logic are covered by the unit suite
(`Tests/GoToBedCoreTests`): firing on active days and not others (AC-2),
auto/manual dismissal timing logic (AC-3), per-schedule appearance + inherited
defaults (AC-5), enable/disable (AC-6), persistence across restart (AC-7),
sleep-skip (AC-8), and no-network (AC-11, via the verify script).

The following require a running app / device and are **manual verification
steps** (tracked as deferred in the PRD):

- **AC-1 / AC-4 (overlay appears, `Esc`/`Cmd-Tab` behavior):** launch the app,
  create a schedule ~1 min out, confirm the overlay appears within ±2s and that
  `Esc` dismisses while `Cmd-Tab` is never blocked.
- **AC-10 (idle CPU ≈ 0%, memory < 80 MB):** measure with Activity Monitor /
  Instruments while idle. The design is event-driven (no polling).
- **30-day soak (NFR-rel-4):** run continuously and confirm no drift or timer
  leaks. The single-timer re-arm design prevents accumulation.
- **VoiceOver audit (NFR-a11y-1):** labels are implemented; run a VoiceOver
  session over the create-schedule and dismiss flows to confirm.

## Releasing (maintainers)

Releases are automated by `.github/workflows/release.yml`: push a `vX.Y.Z` tag
and CI builds the universal binary, signs + notarizes it, packages a DMG, and
publishes a GitHub Release. The version is derived from the tag and injected
into the bundle (shown in the menu).

Required repository secrets:

| Secret | What |
|--------|------|
| `BUILD_CERTIFICATE_BASE64` | base64 of your Developer ID Application `.p12` |
| `P12_PASSWORD` | password for that `.p12` |
| `KEYCHAIN_PASSWORD` | any throwaway string (temp CI keychain) |
| `SIGN_IDENTITY` | e.g. `Developer ID Application: Your Name (TEAMID)` |
| `NOTARY_KEY_BASE64` | base64 of the App Store Connect API `.p8` |
| `NOTARY_KEY_ID` / `NOTARY_ISSUER_ID` | the key's ID and issuer UUID |

To build a signed DMG locally instead:

```sh
./scripts/build-app.sh "Developer ID Application: Your Name (TEAMID)" <notary-profile>
./scripts/make-dmg.sh <notary-profile>
```

where `<notary-profile>` is a `xcrun notarytool store-credentials` keychain profile.

## License

[MIT](LICENSE) © Nick Daniel · An [En Dash](https://endash.us) project.
