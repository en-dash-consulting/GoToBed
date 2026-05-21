# Product Requirements Document — GoToBed

GoToBed is a lightweight macOS menu-bar app that presents a full-screen overlay (similar to a screensaver) at user-scheduled times of day. Each overlay displays the current time and a custom message. The product's focus is the **nightly bedtime nudge** — a hard-to-ignore but non-destructive prompt to stop and go to bed — though schedules and messages are fully user-defined and work equally well for breaks or end-of-day reminders.

- **Status:** Draft
- **Author:** Nick Daniel
- **Last updated:** 2026-05-20
- **Platform:** macOS (native)

---

## 1. Overview & Goals

### 1.1 Problem
People want a hard-to-ignore but non-destructive nudge at specific times of day (bedtime, end of a focus block, time to take a break). A standard notification is too easy to miss or dismiss reflexively. A full-screen overlay interrupts the visual field enough to register, without being a system-level lock.

### 1.2 Solution
A small always-running app that lets the user define a set of scheduled times, each with its own message and its own set of active days of the week. When a schedule fires, the app draws a full-screen overlay showing the live clock and that schedule's message. The user can lightly theme the overlay (colors, font sizes). The overlay is intentionally **escapable** — it is a reminder, not a kiosk lock. It fires **only while the Mac is awake and in use**; occurrences that fall while the machine is asleep are simply skipped.

### 1.3 Goals
- Fire reliably at the configured local time, every day, while the app is running.
- Present a clean, legible full-screen overlay with the current time and a custom message.
- Support multiple independent schedules, each with its own message and dismissal behavior.
- Offer minimal but meaningful appearance customization.
- Stay out of the way: tiny footprint, no dock icon required, optional launch-at-login.

### 1.4 Non-Goals (v1)
- No cross-platform support (macOS only).
- No calendar/date-based scheduling (only recurring weekly times by day-of-week).
- No firing while the Mac is asleep — occurrences during sleep are skipped, not deferred to wake.
- No system-level lockout, password gate, or forced screen lock.
- No cloud sync, accounts, or networking of any kind.
- No audio/sound playback, media, or notifications beyond the overlay itself.

---

## 2. Users & Use Cases

**Primary user:** A single individual configuring reminders for their own machine. Comfortable with basic settings, not necessarily technical.

**Representative use cases:**
1. *Bedtime nudge (primary)* — At 22:30 Sunday–Thursday, cover the screen with "Time to wind down. Go to bed." Auto-dismiss after 60 seconds so it doesn't trap a running task. A separate weekend schedule fires at 23:30 Friday/Saturday.
2. *Break reminder* — At 12:00 and 15:30 on weekdays, show "Step away from the screen for 10 minutes." Require manual dismissal to force acknowledgment.
3. *End-of-day* — At 18:00 Monday–Friday, show "Stop working." with large text and a warm color.

---

## 3. Functional Requirements

### 3.1 Schedules
- **FR-1** The user can create, edit, and delete schedules. There is no enforced upper limit; the UI should remain usable up to at least 24 schedules.
- **FR-2** Each schedule has:
  - A **time of day** (hour + minute, local time, 24h or 12h display per system locale).
  - A set of **active days of the week** (any subset of Sun–Sat; at least one required). Convenience presets: Every day, Weekdays, Weekends.
  - A **message** (free text, multi-line allowed; reasonable cap ~500 chars).
  - An **enabled/disabled** toggle.
  - A **dismissal mode** (see §3.3): *auto-dismiss after duration* or *manual dismiss*.
  - For auto-dismiss schedules, a **duration** in seconds (default 60s, range 5s–3600s).
- **FR-3** Schedules recur **weekly**. A schedule fires once on each of its active days, at its configured time.
- **FR-4** If the configured time has already passed today (or today is not an active day) when a schedule is created/enabled, it fires at its next active-day occurrence (it does not fire immediately).
- **FR-5** Disabled schedules never fire and are visually distinct in the list.
- **FR-5a** A schedule fires **only while the Mac is awake**. If an active-day occurrence falls while the machine is asleep, that occurrence is skipped (and logged); it is **not** deferred and fired on wake.

### 3.2 Overlay presentation
- **FR-6** When a schedule fires, the app displays a full-screen overlay window covering the **active display**. (Multi-display behavior: see §3.6.)
- **FR-7** The overlay displays:
  - The **current time**, updating live at least once per second.
  - The schedule's **message**.
- **FR-8** The overlay is a **soft overlay**: it visually covers the screen (including over the menu bar and Dock area) but does **not** trap the user. The following always remain available:
  - `Esc` and the configured dismiss key dismiss the overlay immediately.
  - `Cmd-Tab` app switching, Mission Control, and force-quit continue to function.
- **FR-9** Only one overlay is shown at a time. If a second schedule fires while an overlay is visible, the new one **replaces** it immediately (the newer message wins). See §3.5.

### 3.3 Dismissal behavior (per-schedule)
- **FR-10** *Auto-dismiss mode:* the overlay dismisses itself after the schedule's configured duration. A subtle countdown or progress indication is shown. The user may still dismiss early via key/click.
- **FR-11** *Manual-dismiss mode:* the overlay stays until the user presses the dismiss key (`Esc` by default) or clicks a clearly labeled dismiss control. No timeout.
- **FR-12** Dismissal is instantaneous (with a brief fade animation, see NFR-perf).

### 3.4 Appearance configuration (per-schedule)
- **FR-13** Each schedule has its own appearance settings, configurable from its editor. At minimum:
  - **Background color** (color picker; supports opacity).
  - **Text color** (color picker).
  - **Clock font size** (e.g. small/medium/large or a point-size slider).
  - **Message font size** (independent of clock size).
- **FR-14** Appearance settings persist with their schedule across launches and apply live to that schedule's next overlay (and to a live preview in the editor, if shown).
- **FR-15** The app holds an **app-wide default appearance**; new schedules are created pre-populated with it so the app is usable with minimal effort. Defaults: dark translucent background, light text, large clock. The user may edit the app-wide default; doing so does **not** retroactively change existing schedules.

### 3.5 Overlay collision handling
- **FR-16** If a schedule fires while another overlay is already visible, the new overlay **replaces** the current one (the newer message wins); overlays are never stacked or queued. Two schedules configured for the exact same minute resolve to whichever fires last by creation order. This edge case is acceptable to keep simple.

### 3.6 Multi-display
- **FR-17** v1 covers the display containing the **main/active screen** (the one with the menu bar). Extending coverage to all attached displays is a future enhancement (§9). The overlay must not crash or misbehave when displays are connected/disconnected while idle.

### 3.7 App lifecycle & access
- **FR-18** The app runs as a **menu-bar (status item) app** with no required Dock icon (`LSUIElement`). Clicking the menu-bar icon opens the settings/schedules window.
- **FR-19** The menu provides: open settings, a list/quick-toggle of schedules, "preview overlay," quit, and a launch-at-login toggle.
- **FR-20** **Launch at login** is user-toggleable (off by default).
- **FR-21** Quitting the app stops all scheduling. (No background daemon persists after quit in v1.)

---

## 4. Non-Functional Requirements (NFRs)

### 4.1 Reliability & timing
- **NFR-rel-1** A schedule must fire within **±2 seconds** of its configured wall-clock time while the app is running and the machine is awake.
- **NFR-rel-2 (sleep handling)** The app fires **only while the Mac is awake**. If the machine is **asleep** at a schedule's time, that occurrence is **skipped** (and logged) — it is never deferred and fired on wake. This must be explicit and tested, since `Timer` does not fire during sleep and a naïve recompute on wake would otherwise replay a missed time.
- **NFR-rel-3 (clock changes)** Scheduling must remain correct across system clock changes, timezone changes, and DST transitions — schedules are interpreted in the current local time, recomputed when the system signals a significant time change.
- **NFR-rel-4** The app must run continuously for ≥ 30 days without requiring a restart, drift, or leaking timers.

### 4.2 Performance & footprint
- **NFR-perf-1** Idle CPU usage ≈ 0% (event/timer driven; no polling loops). Idle resident memory < 80 MB.
- **NFR-perf-2** Overlay appears within **150 ms** of a schedule firing; fade animation ≤ 300 ms.
- **NFR-perf-3** Live clock update incurs negligible CPU (< 1% on a single core while displayed).

### 4.3 Usability
- **NFR-use-1** A first-time user can create a working schedule in under 60 seconds without documentation.
- **NFR-use-2** The dismiss affordance is discoverable: in manual mode, an on-screen hint ("Press Esc to dismiss") is shown.
- **NFR-use-3** Text must remain legible at default settings on Retina and non-Retina displays; respect Dynamic Type / large-size choices without clipping.
- **NFR-use-4** Color pickers should warn (or auto-adjust) if text and background contrast is too low to read.

### 4.4 Compatibility
- **NFR-compat-1** Minimum supported OS is **macOS 13 (Ventura)**; supports 13 and later. SwiftUI and `SMAppService` APIs used must be available on 13.
- **NFR-compat-2** Universal binary (Apple Silicon + Intel).

### 4.5 Privacy & security
- **NFR-priv-1** Fully offline. No telemetry, analytics, or network access. This should be verifiable (no networking entitlements).
- **NFR-priv-2** All user data (schedules, appearance) stored locally only.

### 4.6 Persistence
- **NFR-persist-1** Schedules and settings survive app restart, crash, and OS reboot.
- **NFR-persist-2** Data format is human-readable/recoverable (JSON or `UserDefaults`/`Codable`), so corruption is debuggable and a bad file degrades gracefully to defaults rather than crashing.

### 4.7 Accessibility
- **NFR-a11y-1** The overlay and settings support VoiceOver labeling for key controls.
- **NFR-a11y-2** Honor "Reduce Motion" — skip/shorten fade animations when set.

### 4.8 Observability
- **NFR-obs-1** A lightweight local log (e.g. via `os_log`) records schedule fires, skips (due to sleep/grace window), and dismissals, to aid debugging reliability issues.

---

## 5. Technical Design

### 5.1 Stack
- **Language/UI:** Swift + SwiftUI, with AppKit interop where SwiftUI is insufficient (notably the overlay window).
- **Target:** macOS native app, distributed as a standalone `.app`.
- **Build:** Xcode project / Swift Package. Universal binary.

### 5.2 Architecture (high level)
```
┌─────────────────────────────────────────────────────┐
│ App (LSUIElement, menu-bar status item)              │
│                                                       │
│  ┌────────────┐   ┌──────────────┐   ┌─────────────┐ │
│  │ Settings UI │   │ Scheduler     │   │ Overlay      │ │
│  │ (SwiftUI)   │──▶│ (timer/wake   │──▶│ Presenter    │ │
│  │             │   │  aware)       │   │ (NSWindow)   │ │
│  └────────────┘   └──────────────┘   └─────────────┘ │
│         │                  │                  │       │
│         ▼                  ▼                  ▼       │
│   ┌──────────────────────────────────────────────┐   │
│   │ Store (Codable → JSON / UserDefaults)         │   │
│   └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

**Components:**
- **Store** — owns `AppState` (the `[Schedule]`, each with its own `AppearanceSettings`, plus the default appearance); loads/saves via `Codable`. Single source of truth, observable.
- **Scheduler** — computes the next fire `Date` for each enabled schedule and arms timers. Listens for system wake (`NSWorkspace.didWakeNotification`) and significant time change (`NSSystemClockDidChange`) to recompute. Emits a "schedule fired" event.
- **OverlayPresenter** — on a fire event, builds a borderless full-screen `NSWindow` at an appropriate window level, hosts a SwiftUI overlay view styled by the firing schedule's `AppearanceSettings`, and manages dismissal (auto-timer or key/click). If an overlay is already visible it replaces it (FR-16).
- **Settings UI** — SwiftUI views for the schedule list/editor and appearance controls, plus a "preview overlay" action.

### 5.3 Data model (illustrative)
```swift
struct Schedule: Codable, Identifiable {
    let id: UUID
    var hour: Int            // 0–23, local time
    var minute: Int          // 0–59
    var weekdays: Set<Int>   // 1=Sun … 7=Sat (Calendar.weekday), non-empty
    var message: String
    var isEnabled: Bool
    var dismissMode: DismissMode      // .auto(seconds: Int) or .manual
    var appearance: AppearanceSettings // per-schedule; seeded from app default on create
}

enum DismissMode: Codable {
    case auto(seconds: Int)   // default 60
    case manual
}

struct AppearanceSettings: Codable {
    var backgroundColor: ColorComponents   // RGBA
    var textColor: ColorComponents
    var clockFontSize: Double
    var messageFontSize: Double
}

// App-wide state: the schedules plus the default appearance new schedules inherit.
struct AppState: Codable {
    var schedules: [Schedule]
    var defaultAppearance: AppearanceSettings
}
```

### 5.4 The overlay window (key technical detail)
- Use a borderless `NSWindow` (`styleMask = .borderless`) sized to the target screen's `frame`.
- Set `window.level` high enough to cover the menu bar and Dock (e.g. `.screenSaver` / `NSWindow.Level(rawValue: CGShieldingWindowLevel())`), and `collectionBehavior` to appear across spaces and over fullscreen apps where possible.
- Because this is a **soft overlay**, do **not** capture the event tap or disable the dock/menu-bar globally. `Esc` and a dismiss control return control immediately. `Cmd-Tab` and force-quit remain functional by design.
- Host the SwiftUI overlay view via `NSHostingView`.
- Make the window key/front to receive the dismiss keypress, but avoid `presentationOptions` that hide the menu bar permanently — restore state on dismiss.

- For each enabled schedule, compute the next occurrence as the soonest `Calendar.current.nextDate(after:matching:DateComponents(hour:minute:weekday:))` over the schedule's active weekdays. (Compute one candidate per active weekday and take the minimum, or iterate `nextDate` forward until the matched weekday is in the set.)
- Arm a timer for the soonest fire across all schedules. On fire: present overlay, then recompute that schedule's next occurrence.
- **Sleep/skip (NFR-rel-2):** `Timer` does not fire while asleep. On `NSWorkspace.didWakeNotification`, **recompute all next-fire dates forward from "now"** — deliberately discarding any occurrence whose time has already passed — so a time missed during sleep is skipped rather than replayed. Log each skip.
- **Clock/timezone change:** on `NSSystemClockDidChange` / `NSSystemTimeZoneDidChange`, recompute all timers.
- Prefer a single coalesced timer to the next event over N independent long-lived timers, to bound drift and resource use.

### 5.6 Persistence
- Encode `AppState` (schedules with their per-schedule appearance, plus the default appearance) as JSON in Application Support, or store via `UserDefaults` with `Codable`. On decode failure, fall back to defaults and log (NFR-persist-2).

### 5.7 Packaging & permissions
- `LSUIElement = true` (no Dock icon; menu-bar only).
- Launch-at-login via `SMAppService` (modern API) toggled from settings.
- No special entitlements expected for a soft overlay; **no** networking, camera, mic, accessibility, or screen-recording entitlements. (Confirm during build that drawing above the menu bar at the chosen window level works without Accessibility permission; if a future "hard takeover" mode is added it would require additional entitlements — out of scope here.)
- Code-sign for local/personal use; notarization optional unless distributing.

---

## 6. UX Notes

- **Menu-bar menu:** icon → popover or window listing schedules with inline enable toggles; buttons for "Add schedule," "Settings," "Preview overlay," "Launch at login," "Quit."
- **Schedule editor:** time picker, day-of-week selector (seven toggles plus Every day / Weekdays / Weekends presets), message text field (multi-line), dismissal mode segmented control (Auto / Manual), duration stepper (shown only for Auto), enabled toggle, and an **Appearance section** (background color, text color, clock size, message size) with a live preview tile reflecting that schedule's settings.
- **Default appearance:** a settings pane to edit the app-wide default appearance used to seed new schedules.
- **Overlay:** large centered clock, message below it, subtle dismiss hint, and (auto mode) an unobtrusive countdown/progress ring. Honors Reduce Motion.

---

## 7. Acceptance Criteria

1. Creating a schedule for a time ~1 minute in the future on today's weekday causes a full-screen overlay to appear within ±2s showing the live clock and the message.
2. A schedule fires only on its active days: it does **not** fire on a non-active day, and does fire on the next active day.
3. Auto-dismiss schedules disappear after the configured duration; manual schedules persist until `Esc`/click.
4. `Esc` always dismisses; `Cmd-Tab` and force-quit are never blocked.
5. A schedule's appearance changes (colors, sizes) are reflected in that schedule's next overlay and its editor preview, and do not affect other schedules. New schedules inherit the app-wide default appearance.
6. Disabling a schedule prevents it from firing; re-enabling restores it.
7. Schedules and appearance survive an app restart and a reboot.
8. A schedule whose time passes while the Mac is asleep does **not** fire on wake; the occurrence is skipped and logged, and the next future occurrence is armed correctly.
9. App runs as menu-bar-only with no Dock icon; launch-at-login toggle works.
10. Idle CPU is effectively 0% and memory stays within budget.
11. App makes no network connections.

---

## 8. Risks & Open Questions

- **Drawing above the menu bar / over fullscreen apps** can be finicky across macOS versions and window levels; needs early prototyping to confirm the chosen level behaves on the target OS.
- **Sleep skip vs. replay** is the most likely source of bugs: the recompute-forward-from-now logic (NFR-rel-2) must be tested so a missed-during-sleep time is never replayed on wake. Decided: skip, never fire on wake.

---

## 9. Future Enhancements (out of scope for v1)

- All-displays coverage.
- Optional sound/chime.
- "Hard takeover" mode (kiosk-style, requires extra entitlements and careful escape handling).
- Snooze action on the overlay.
- Import/export of schedules.
