## Summary

**Branch:** `sv`
**Base:** `main`
**Completed items:** 95

| Epic | Completed |
|------|-----------|
| App Shell & Foundation | 11 |
| Data Model & Persistence | 10 |
| Distribution & Releases | 12 |
| Overlay Presentation | 17 |
| Scheduler Engine | 15 |
| Settings & Schedule UI | 15 |
| System Integration & Quality | 9 |

## ⚠️ Breaking Changes

- **Offline-preserving update path**
  Give users a clear path to updates without breaking the app's zero-network guarantee (NFR-priv-1). Add a "Check for Updates…" menu item that opens the latest GitHub release page in the default browser (NSWorkspace.open — no network entitlement), show the current version in the menu, and document the manual update flow (download the new .app, replace it in /Applications). Note: a true in-app auto-updater (e.g. Sparkle) was deliberately not chosen because it requires network access; recorded here as a future option if the privacy stance is ever relaxed.
  - Menu shows current version and a 'Check for Updates…' item that opens the releases page in the browser
  - No network entitlement added; scripts/verify-no-network.sh still passes
  - Manual update steps documented in README and on the website

## Major Changes

- **App Shell & Foundation** [high]
  Project scaffolding and the menu-bar app shell for GoToBed — a macOS 13+ SwiftUI/AppKit app distributed as a standalone universal .app. Establishes the LSUIElement menu-bar status-item app with no Dock icon, the menu actions, and local os_log observability. Foundation for all other epics.
- **Data Model & Persistence** [high]
  The Codable domain model (Schedule, DismissMode, AppearanceSettings, AppState) and the single observable Store that owns app state. Persists schedules and appearance to local JSON with graceful degradation to defaults on decode failure. Survives restart, crash, and reboot (NFR-persist).
- **Overlay Presentation** [critical]
  The full-screen "soft overlay" shown when a schedule fires: a borderless NSWindow at shield/screensaver level covering the active display, hosting a SwiftUI view with a live clock and the schedule's message. Implements auto and manual dismissal, escapability (Esc/Cmd-Tab/force-quit never trapped), collision replacement (newer wins), fade animation, and Reduce Motion.
- **Borderless full-screen overlay window** [critical]
  A borderless NSWindow sized to the active screen (the one with the menu bar), at a high level (screensaver/CGShieldingWindowLevel) with collectionBehavior to appear across spaces and over fullscreen apps, covering the menu bar and Dock. Hosts SwiftUI content via NSHostingView. Must not crash on display connect/disconnect while idle.
- **Create borderless NSWindow at shield level sized to active screen** [critical]
  Borderless NSWindow at CGShieldingWindowLevel covering the active screen's frame.
- **Scheduler Engine** [critical]
  The timing core: computes each enabled schedule's next weekly fire date, arms a single coalesced timer to the soonest event, and emits fire events. Handles sleep/wake by recomputing forward from now (skip, never replay missed occurrences) and recomputes on system clock/timezone/DST changes. Highest-risk area — must fire within ±2s while awake and run ≥30 days without drift or timer leaks.
- **Coalesced timer arming & fire events** [critical]
  Arm a single coalesced timer to the soonest fire across all schedules (rather than N long-lived timers) to bound drift and resource use. On fire, emit a "schedule fired" event and recompute that schedule's next occurrence. Must fire within ±2s and run ≥30 days without drift or timer leaks.
- **Compute soonest fire and arm a single coalesced timer** [critical]
  Find the minimum next-fire across all enabled schedules and schedule one timer to it.
- **Emit fire event and re-arm to next occurrence** [critical]
  On fire, publish the firing schedule to the overlay presenter, then recompute and re-arm.
- **Next-fire computation across active weekdays** [critical]
  Compute each enabled schedule's soonest next occurrence using Calendar.nextDate over its active weekdays (one candidate per weekday, take the minimum). Already-passed-today or non-active-day schedules resolve to the next active-day occurrence — never fire immediately on create/enable.
- **Handle passed-today / non-active-day → next active occurrence** [critical]
  Ensure newly created/enabled schedules never fire immediately (FR-4).
- **Implement per-weekday next-occurrence computation** [critical]
  Use Calendar.nextDate(after:matching:) per active weekday and take the minimum future date.
- **Sleep/wake skip handling (recompute-forward)** [critical]
  Fire only while the Mac is awake. On NSWorkspace.didWakeNotification, recompute all next-fire dates forward from now, discarding any occurrence whose time passed during sleep — so a missed-during-sleep time is skipped and logged, never replayed on wake. The single most bug-prone area; must be explicitly tested.
- **Observe didWakeNotification and recompute-forward-from-now** [critical]
  On wake, discard all stale next-fire dates and recompute from the current time.
- **Skip and log occurrences missed during sleep (never replay)** [critical]
  Ensure a time that passed during sleep does not fire on wake; log the skip (NFR-rel-2).
- **Settings & Schedule UI** [high]
  The SwiftUI settings surface: the menu-bar menu with inline schedule quick-toggles, the schedule list/editor (time, day-of-week presets, message, dismissal mode, duration, enabled), per-schedule appearance controls with a live preview tile, the app-wide default appearance pane, and the "preview overlay" action. A first-time user can create a working schedule in under 60s.
- **System Integration & Quality** [medium]
  Cross-cutting integration and quality work: launch-at-login via SMAppService, accessibility (VoiceOver labels, low-contrast warnings, Reduce Motion), privacy & packaging (no network/camera/mic entitlements, universal binary, code-signing), and a final pass validating the §7 acceptance criteria and NFR budgets.

## Completed Work

### App Shell & Foundation

**Local os_log observability**
- Add log points for fires, sleep-skips, and dismissals
  Emit structured log entries at fire, sleep-skip, and dismissal events (NFR-obs-1).
- Define os_log Logger categories
  Create Logger instances for scheduler, overlay, and persistence subsystems.

**Menu-bar status-item app (LSUIElement)**
- Create NSStatusItem with icon and menu
  Add a status-bar item with a template icon and attach the popover/menu.
- Implement quit path that tears down scheduler and timers
  On quit, invalidate timers and stop scheduling so no work persists after exit (FR-21).
- Wire menu actions (settings, preview, launch-at-login, quit)
  Hook each menu command to its handler; open the settings window from the menu.

**Project scaffold (SwiftPM/Xcode, universal, macOS 13+)**
- Add @main SwiftUI App entry point with AppDelegate hook
  Wire the app entry point and an NSApplicationDelegateAdaptor for AppKit interop (status item, overlay window).
- Configure universal binary build settings and Info.plist (LSUIElement)
  Set arm64+x86_64 universal build and add Info.plist keys including LSUIElement=true.
- Initialize SwiftPM/Xcode project with macOS 13 target
  Set up the app project (Swift + SwiftUI) targeting macOS 13, with a runnable scheme and documented build/test commands.

- Local os_log observability *(feature)*
  A lightweight local logging facility via os_log that records schedule fires, skips (sleep/grace), and dismissals to aid debugging of reliability issues. Used by the scheduler and overlay subsystems.
  - Fires, sleep-skips, and dismissals are logged via os_log (NFR-obs-1)
  - Log categories are inspectable in Console.app
- Menu-bar status-item app (LSUIElement) *(feature)*
  Run as a menu-bar (status item) app with LSUIElement=true (no Dock icon). The menu provides: open settings, schedule list with inline quick-toggles, preview overlay, launch-at-login toggle, and quit. Quitting stops all scheduling.
  - App shows a menu-bar icon and no Dock icon (FR-18)
  - Menu exposes settings, schedule toggles, preview, launch-at-login, quit (FR-19)
  - Quit stops all scheduling and leaves no daemon (FR-21)
- Project scaffold (SwiftPM/Xcode, universal, macOS 13+) *(feature)*
  Create the buildable app project targeting macOS 13 (Ventura)+ as a universal binary (Apple Silicon + Intel), Swift + SwiftUI with AppKit interop. Produces a standalone .app that launches.
  - Project builds a runnable macOS 13+ universal .app
  - SwiftUI app entry point launches without a Dock icon
  - Build/test commands documented in repo

### Data Model & Persistence

**Core domain model (Schedule, DismissMode, AppearanceSettings, AppState)**
- Add ColorComponents RGBA type with Codable
  Codable RGBA representation plus conversions to/from SwiftUI Color / NSColor.
- Add model validation (weekdays, duration, message cap)
  Enforce non-empty weekdays, auto duration 5-3600s, and ~500-char message cap.
- Define Schedule/DismissMode/AppearanceSettings/AppState Codable types
  Implement the §5.3 model exactly, with Codable conformance and Identifiable Schedule.

**JSON persistence with graceful fallback**
- Add graceful decode-failure fallback to defaults with logging
  On corrupt/missing file, load defaults and log instead of crashing (NFR-persist-2).
- Implement Application Support JSON load/save of AppState
  Encode/decode AppState as JSON in Application Support; save on change.

**Observable Store (single source of truth)**
- Implement observable Store owning AppState with CRUD
  An ObservableObject Store with add/edit/delete schedule and default-appearance editing, publishing changes.
- Seed new schedules from default appearance
  When creating a schedule, copy the current app-wide default appearance into it (FR-15).

- Core domain model (Schedule, DismissMode, AppearanceSettings, AppState) *(feature)*
  The Codable value types: Schedule (id, hour, minute, weekdays Set, message, isEnabled, dismissMode, appearance), DismissMode (.auto(seconds:)/.manual), AppearanceSettings (RGBA bg/text colors, clock & message font sizes), and AppState (schedules + defaultAppearance). Includes validation invariants (non-empty weekdays, duration 5s–3600s, message cap ~500 chars).
  - Types match the §5.3 model and are Codable
  - Weekdays cannot be empty; duration constrained to 5-3600s; message capped ~500 chars
  - Round-trips through Codable without loss
- JSON persistence with graceful fallback *(feature)*
  Persist AppState as human-readable JSON in Application Support (or UserDefaults via Codable). On decode failure, fall back to defaults and log rather than crash. Data survives app restart, crash, and OS reboot.
  - AppState persists and reloads across restart/reboot (NFR-persist-1)
  - Corrupt/unreadable file degrades gracefully to defaults and logs (NFR-persist-2)
  - Stored format is human-readable JSON
- Observable Store (single source of truth) *(feature)*
  An observable Store that owns AppState as the single source of truth, exposes CRUD on schedules and the default appearance, and notifies observers (UI and scheduler) of changes. New schedules are seeded from the app-wide default appearance.
  - Store is observable; UI and scheduler react to changes
  - Create/edit/delete schedule and edit default appearance supported
  - New schedules inherit current default appearance (FR-15)

### Distribution & Releases

**Developer ID signing & notarization**
- Add Developer ID signing + notarytool + stapling to build-app.sh
  Extend build-app.sh to sign with a Developer ID Application identity (hardened runtime), submit to notarytool, and staple the ticket; parameterize identity/credentials. Verify with spctl.

**Download website on GitHub Pages**
- Build the static landing/download page
  A clean single-page site (pitch, overlay screenshot, Download button to latest release) in docs/ or a gh-pages branch; mobile-legible, En Dash branding.
- Configure GitHub Pages + CNAME for gotobed.endash.us
  Enable GitHub Pages, add CNAME for gotobed.endash.us, configure the DNS record, and confirm HTTPS serves the site.

**Offline-preserving update path**
- Add 'Check for Updates…' menu item + version display
  Menu shows the current version and a 'Check for Updates…' item that opens the latest releases page via NSWorkspace.open (no network entitlement). Confirm verify-no-network still passes.
- Document the manual update flow (README + website)
  Document how to update: download the new .app from releases, replace the copy in /Applications, relaunch. Surface in README and on the site.

**Open-source the repository (MIT)**
- Add MIT LICENSE and finalize public README
  Add an MIT LICENSE file, ensure README is public-ready, and confirm no secrets/credentials are committed.

**Versioned, automated releases**
- Derive version from git tag, inject into Info.plist, show in menu
  Single-source the version from the git tag (vX.Y.Z) into CFBundleShortVersionString + CFBundleVersion at build time; display the running version in the menu.
- GitHub Actions release workflow (build, sign, notarize, publish on tag)
  CI workflow triggered on vX.Y.Z tags: build universal, sign + notarize (secrets for identity/credentials), package, and create a GitHub Release with auto-generated notes and the download asset.
- Package signed app as .dmg/.zip download artifact
  Produce a distributable .dmg (and/or zip) of the notarized GoToBed.app as the downloadable release asset.

- ⚠️ **Offline-preserving update path** *(feature)*
  Give users a clear path to updates without breaking the app's zero-network guarantee (NFR-priv-1). Add a "Check for Updates…" menu item that opens the latest GitHub release page in the default browser (NSWorkspace.open — no network entitlement), show the current version in the menu, and document the manual update flow (download the new .app, replace it in /Applications). Note: a true in-app auto-updater (e.g. Sparkle) was deliberately not chosen because it requires network access; recorded here as a future option if the privacy stance is ever relaxed.
  - Menu shows current version and a 'Check for Updates…' item that opens the releases page in the browser
  - No network entitlement added; scripts/verify-no-network.sh still passes
  - Manual update steps documented in README and on the website
- Developer ID signing & notarization *(feature)*
  Replace the current ad-hoc signature with Developer ID Application signing under the hardened runtime, notarize the app with Apple (notarytool), and staple the ticket, so a downloaded build launches without Gatekeeper warnings or right-click-open. Requires an Apple Developer account ($99/yr); this is the main prerequisite for a smooth public download.
  - Release .app is signed with a Developer ID Application identity and hardened runtime
  - Notarization via notarytool succeeds and the ticket is stapled
  - spctl --assess --type execute passes; first launch shows no 'unidentified developer' block
  - Entitlements remain network-free (no-network guarantee preserved)
- Versioned, automated releases *(feature)*
  A single-source semantic version driven by git tags (vX.Y.Z), injected into Info.plist (CFBundleShortVersionString + build number) and surfaced in the app, plus a downloadable artifact and CI automation: on a version tag push, GitHub Actions builds the universal binary, signs + notarizes it, packages it (DMG/zip), and publishes a GitHub Release with auto-generated notes and the download asset.
  - Version is derived from the git tag and written into Info.plist at build time
  - App displays its version (e.g. in the menu)
  - Pushing a vX.Y.Z tag publishes a GitHub Release with a notarized universal download asset and release notes

### Overlay Presentation

**Borderless full-screen overlay window**
- 🔶 **Create borderless NSWindow at shield level sized to active screen**
  Borderless NSWindow at CGShieldingWindowLevel covering the active screen's frame.
- Prototype window level on macOS 13; handle display connect/disconnect
  Confirm coverage over menu bar/Dock without Accessibility permission; survive display changes while idle (risk item §8).
- Set collectionBehavior and host NSHostingView
  Configure across-spaces/over-fullscreen behavior; embed the SwiftUI overlay via NSHostingView.

**Dismissal behavior (auto, manual, escapable)**
- Ensure Cmd-Tab/force-quit unblocked; restore menu-bar state on dismiss
  Do not capture event taps or hide the menu bar permanently; verify escapability (FR-8, AC-4).
- Implement auto-dismiss timer with countdown/progress ring
  Auto mode dismisses after the configured duration with a subtle countdown; allow early dismiss.
- Implement manual dismiss via Esc/control with hint
  Manual mode persists until Esc or a labeled dismiss control; show 'Press Esc to dismiss' hint.

**Fade animation & Reduce Motion**
- Add present/dismiss fade animations within perf budget
  Fade in/out ≤300ms; overlay visible within 150ms of fire (NFR-perf-2).
- Honor Reduce Motion by skipping/shortening fades
  Detect accessibilityReduceMotion and present/dismiss without animation (NFR-a11y-2).

**Overlay collision replacement (newer wins)**
- Resolve same-minute collisions by creation order
  Deterministic last-writer-wins ordering for two schedules at the same minute.
- Track single active overlay and replace on new fire
  Hold a reference to the current overlay; on a new fire, tear it down and show the new one (FR-16).

**SwiftUI overlay view (live clock + message)**
- Build overlay layout: centered live clock, message, dismiss hint
  SwiftUI layout with large clock, message below, subtle dismiss hint; legible on Retina/non-Retina.
- Drive live clock with 1s timeline; style from AppearanceSettings
  Update the clock at least once per second with negligible CPU; apply schedule colors/font sizes.

- 🔶 **Borderless full-screen overlay window** *(feature)*
  A borderless NSWindow sized to the active screen (the one with the menu bar), at a high level (screensaver/CGShieldingWindowLevel) with collectionBehavior to appear across spaces and over fullscreen apps, covering the menu bar and Dock. Hosts SwiftUI content via NSHostingView. Must not crash on display connect/disconnect while idle.
  - Overlay covers the active display including menu bar and Dock (FR-6)
  - Window level/collectionBehavior verified on macOS 13 (early prototype — risk item)
  - No crash/misbehavior when displays connect or disconnect while idle (FR-17)
- Dismissal behavior (auto, manual, escapable) *(feature)*
  Per-schedule dismissal: auto-dismiss after the configured duration with a subtle countdown/progress ring (early dismiss allowed), or manual until Esc/dismiss control. The overlay is a soft overlay — Esc and the dismiss control always work, and Cmd-Tab, Mission Control, and force-quit are never blocked. Menu-bar state restored on dismiss.
  - Auto-dismiss disappears after duration with countdown shown; manual persists until Esc/click (AC-3, FR-10/11)
  - Esc always dismisses; Cmd-Tab and force-quit never blocked (AC-4, FR-8)
  - Manual mode shows a discoverable 'Press Esc to dismiss' hint (NFR-use-2)
- Fade animation & Reduce Motion *(feature)*
  Brief fade animation on present/dismiss (≤300ms); overlay appears within 150ms of fire. Honor the system "Reduce Motion" setting by skipping/shortening animations.
  - Overlay appears within 150ms; fade ≤300ms (NFR-perf-2)
  - Reduce Motion skips/shortens the fade (NFR-a11y-2)
- Overlay collision replacement (newer wins) *(feature)*
  Only one overlay is ever shown. If a schedule fires while an overlay is visible, the new overlay replaces the current one immediately (newer message wins); overlays are never stacked or queued. Two schedules at the same minute resolve to whichever fires last by creation order.
  - At most one overlay visible at any time (FR-9)
  - A new fire replaces the current overlay immediately (FR-16)
  - Same-minute collision resolves deterministically by creation order
- SwiftUI overlay view (live clock + message) *(feature)*
  The SwiftUI overlay content: a large centered live clock updating at least once per second, the schedule's message below it, and a subtle dismiss hint. Styled by the firing schedule's AppearanceSettings (colors, font sizes). Legible on Retina and non-Retina; respects large-size choices without clipping.
  - Clock updates live ≥1/sec; message displayed (FR-7)
  - View styled by the firing schedule's appearance (FR-13/14)
  - Legible at default settings on Retina/non-Retina without clipping (NFR-use-3)
  - Live clock CPU < 1% on a single core (NFR-perf-3)

### Scheduler Engine

**Clock/timezone/DST change recomputation**
- Observe clock/timezone change notifications and recompute timers
  Handle NSSystemClockDidChange / NSSystemTimeZoneDidChange by recomputing all timers.
- Tests for DST transition correctness
  Assert no double-fire or missed fire across spring-forward/fall-back boundaries.

**Coalesced timer arming & fire events**
- 🔶 **Compute soonest fire and arm a single coalesced timer**
  Find the minimum next-fire across all enabled schedules and schedule one timer to it.
- 🔶 **Emit fire event and re-arm to next occurrence**
  On fire, publish the firing schedule to the overlay presenter, then recompute and re-arm.
- Re-coalesce timer on schedule changes; prevent leaks
  Invalidate and re-arm when schedules are added/edited/toggled; ensure no leaked timers.

**Next-fire computation across active weekdays**
- 🔶 **Handle passed-today / non-active-day → next active occurrence**
  Ensure newly created/enabled schedules never fire immediately (FR-4).
- 🔶 **Implement per-weekday next-occurrence computation**
  Use Calendar.nextDate(after:matching:) per active weekday and take the minimum future date.
- Unit tests for weekday subsets and edge times
  Cover single-day, weekday/weekend presets, midnight boundary, and same-day-passed cases.

**Sleep/wake skip handling (recompute-forward)**
- 🔶 **Observe didWakeNotification and recompute-forward-from-now**
  On wake, discard all stale next-fire dates and recompute from the current time.
- 🔶 **Skip and log occurrences missed during sleep (never replay)**
  Ensure a time that passed during sleep does not fire on wake; log the skip (NFR-rel-2).
- Tests simulating sleep across a scheduled time
  Inject a clock to simulate a wake after a missed fire and assert skip + correct re-arm (AC-8).

- 🔶 **Coalesced timer arming & fire events** *(feature)*
  Arm a single coalesced timer to the soonest fire across all schedules (rather than N long-lived timers) to bound drift and resource use. On fire, emit a "schedule fired" event and recompute that schedule's next occurrence. Must fire within ±2s and run ≥30 days without drift or timer leaks.
  - Single coalesced timer targets the soonest event (FR-rel-1 ±2s)
  - On fire, emits event then re-arms to next occurrence
  - No timer leaks or drift over a 30-day soak (NFR-rel-4)
- 🔶 **Next-fire computation across active weekdays** *(feature)*
  Compute each enabled schedule's soonest next occurrence using Calendar.nextDate over its active weekdays (one candidate per weekday, take the minimum). Already-passed-today or non-active-day schedules resolve to the next active-day occurrence — never fire immediately on create/enable.
  - Next-fire date is correct for arbitrary weekday subsets (FR-3)
  - A schedule whose time already passed today fires at next active occurrence, not immediately (FR-4)
  - Disabled schedules produce no fire date (FR-5)
- 🔶 **Sleep/wake skip handling (recompute-forward)** *(feature)*
  Fire only while the Mac is awake. On NSWorkspace.didWakeNotification, recompute all next-fire dates forward from now, discarding any occurrence whose time passed during sleep — so a missed-during-sleep time is skipped and logged, never replayed on wake. The single most bug-prone area; must be explicitly tested.
  - An occurrence falling during sleep does not fire on wake; it is skipped and logged (AC-8, NFR-rel-2)
  - After wake, the next future occurrence is armed correctly
  - Recompute-forward logic covered by automated tests
- Clock/timezone/DST change recomputation *(feature)*
  Keep scheduling correct across system clock changes, timezone changes, and DST transitions by interpreting schedules in current local time and recomputing all timers on NSSystemClockDidChange / NSSystemTimeZoneDidChange.
  - Timers recompute on clock/timezone change notifications (NFR-rel-3)
  - DST transition does not cause double-fire or missed legitimate fire
  - Schedules interpreted in current local time

### Settings & Schedule UI

**App-wide default appearance pane**
- Build app-wide default appearance settings pane
  Editable default appearance (dark translucent bg, light text, large clock) seeding new schedules; non-retroactive.

**Menu-bar menu & schedule quick-toggle list**
- Add Add/Settings/Preview/Launch-at-login/Quit controls
  Provide all menu actions specified in FR-19.
- Render schedule list with inline toggles and disabled styling
  List schedules in the menu/popover with working enable toggles; disabled ones visually distinct.

**Per-schedule appearance controls & live preview**
- Add color pickers and font-size controls
  Background color with opacity, text color, clock & message font-size controls bound to the schedule.
- Add live preview tile reflecting schedule settings
  A preview tile in the editor that updates live as appearance changes (FR-14).
- Add low-contrast warning / auto-adjust
  Compute text/background contrast and warn or auto-adjust when too low (NFR-use-4).

**Preview overlay action**
- Wire 'preview overlay' to present with selected schedule's settings
  Present the overlay on demand without affecting scheduling; dismissable like a real fire.

**Schedule editor**
- Add dismissal-mode control with conditional duration stepper and enabled toggle
  Auto/Manual segmented control; show duration stepper (5-3600s, default 60) only for Auto; enabled toggle.
- Build editor form: time picker, day selector with presets, message
  Time picker, seven day toggles + Every day/Weekdays/Weekends presets, multi-line message field.
- Wire create/edit/delete to Store with validation
  Persist editor changes through the Store; block invalid input (e.g. no active days).

- App-wide default appearance pane *(feature)*
  A settings pane to edit the app-wide default appearance (dark translucent background, light text, large clock) used to seed new schedules. Editing the default does not retroactively change existing schedules.
  - Default appearance is editable (FR-15)
  - New schedules are pre-populated with the current default
  - Editing the default does not alter existing schedules
- Menu-bar menu & schedule quick-toggle list *(feature)*
  The menu-bar popover/menu listing schedules with inline enable toggles and buttons for Add schedule, Settings, Preview overlay, Launch at login, and Quit. Disabled schedules are visually distinct.
  - Menu lists schedules with working inline enable/disable toggles
  - Disabled schedules are visually distinct (FR-5)
  - Add/Settings/Preview/Launch-at-login/Quit actions present (FR-19)
- Per-schedule appearance controls & live preview *(feature)*
  An Appearance section in the editor: background color (with opacity), text color, clock font size, message font size — each per-schedule. A live preview tile reflects the schedule's settings. Warn or auto-adjust when text/background contrast is too low.
  - Background (w/ opacity), text color, clock & message font sizes editable per schedule (FR-13)
  - Changes reflected in editor preview and the schedule's next overlay, without affecting other schedules (AC-5, FR-14)
  - Low-contrast text/background warns or auto-adjusts (NFR-use-4)
- Preview overlay action *(feature)*
  A "preview overlay" action (from the menu and/or editor) that presents the overlay immediately using a schedule's current settings, so the user can see the result without waiting for a scheduled fire.
  - Preview presents the overlay on demand with the selected schedule's appearance and message
  - Preview overlay is dismissable like a real fire and does not affect scheduling
- Schedule editor *(feature)*
  The SwiftUI schedule editor: time picker; day-of-week selector (seven toggles plus Every day / Weekdays / Weekends presets, at least one required); multi-line message field (~500 char cap); dismissal mode segmented control (Auto/Manual) with a duration stepper shown only for Auto (default 60s, 5–3600s); enabled toggle. Create/edit/delete schedules.
  - Create, edit, delete schedules (FR-1)
  - All schedule fields editable with presets and validation (FR-2)
  - Duration stepper only appears in Auto mode; enforces 5-3600s

### System Integration & Quality

**Acceptance & reliability validation pass**
- Author automated tests for the §7 acceptance criteria
  Cover criteria 1-9 with unit/integration tests where the platform allows.

**Accessibility (VoiceOver, contrast)**
- Add VoiceOver labels to overlay and settings controls
  Label key controls (dismiss, toggles, pickers) for VoiceOver (NFR-a11y-1).

**Launch-at-login via SMAppService**
- Integrate SMAppService register/unregister; reflect state in UI
  Toggle launch-at-login via SMAppService (off by default) and keep the menu/settings toggle in sync.

**Privacy & packaging (no-network, universal, signing)**
- Audit entitlements: remove network/camera/mic/accessibility
  Ensure the entitlements file declares no networking or sensitive-device access (NFR-priv-1).
- Configure universal binary + code signing; verify no network calls
  Code-sign the universal build for local use; verify zero network connections at runtime (AC-11).

- Acceptance & reliability validation pass *(feature)*
  A final verification pass covering the §7 acceptance criteria and the NFR budgets: ±2s fire timing, idle CPU ≈0% / memory <80MB, 150ms overlay appearance, and the sleep-skip behavior. Establishes the automated test suite where feasible.
  - All §7 acceptance criteria (1-11) verified
  - Idle CPU ≈0% and memory <80MB measured (NFR-perf-1, AC-10)
  - Performance and timing NFRs validated
- Accessibility (VoiceOver, contrast) *(feature)*
  VoiceOver labeling for key controls in the overlay and settings. (Reduce Motion is handled in the overlay fade feature; contrast warnings in appearance controls — this feature ensures end-to-end a11y coverage and audit.)
  - Key overlay and settings controls have VoiceOver labels (NFR-a11y-1)
  - A11y audit passes for the primary create-schedule and dismiss flows
- Launch-at-login via SMAppService *(feature)*
  User-toggleable launch-at-login via the modern SMAppService API, off by default, toggled from settings/menu.
  - Launch-at-login toggle works and persists; off by default (FR-20, AC-9)
  - Uses SMAppService (available on macOS 13)
- Privacy & packaging (no-network, universal, signing) *(feature)*
  Ship fully offline: no networking/camera/mic/accessibility/screen-recording entitlements, no telemetry. Universal binary, code-signed for local use (notarization optional). Verify no network connections are made.
  - No network/camera/mic/accessibility entitlements present (NFR-priv-1)
  - App makes no network connections, verified (AC-11)
  - Universal binary, code-signed

### (Ungrouped)

- 🔶 **App Shell & Foundation** *(epic)*
  Project scaffolding and the menu-bar app shell for GoToBed — a macOS 13+ SwiftUI/AppKit app distributed as a standalone universal .app. Establishes the LSUIElement menu-bar status-item app with no Dock icon, the menu actions, and local os_log observability. Foundation for all other epics.
- 🔶 **Data Model & Persistence** *(epic)*
  The Codable domain model (Schedule, DismissMode, AppearanceSettings, AppState) and the single observable Store that owns app state. Persists schedules and appearance to local JSON with graceful degradation to defaults on decode failure. Survives restart, crash, and reboot (NFR-persist).
- 🔶 **Overlay Presentation** *(epic)*
  The full-screen "soft overlay" shown when a schedule fires: a borderless NSWindow at shield/screensaver level covering the active display, hosting a SwiftUI view with a live clock and the schedule's message. Implements auto and manual dismissal, escapability (Esc/Cmd-Tab/force-quit never trapped), collision replacement (newer wins), fade animation, and Reduce Motion.
- 🔶 **Scheduler Engine** *(epic)*
  The timing core: computes each enabled schedule's next weekly fire date, arms a single coalesced timer to the soonest event, and emits fire events. Handles sleep/wake by recomputing forward from now (skip, never replay missed occurrences) and recomputes on system clock/timezone/DST changes. Highest-risk area — must fire within ±2s while awake and run ≥30 days without drift or timer leaks.
- 🔶 **Settings & Schedule UI** *(epic)*
  The SwiftUI settings surface: the menu-bar menu with inline schedule quick-toggles, the schedule list/editor (time, day-of-week presets, message, dismissal mode, duration, enabled), per-schedule appearance controls with a live preview tile, the app-wide default appearance pane, and the "preview overlay" action. A first-time user can create a working schedule in under 60s.
- 🔶 **System Integration & Quality** *(epic)*
  Cross-cutting integration and quality work: launch-at-login via SMAppService, accessibility (VoiceOver labels, low-contrast warnings, Reduce Motion), privacy & packaging (no network/camera/mic entitlements, universal binary, code-signing), and a final pass validating the §7 acceptance criteria and NFR budgets.

