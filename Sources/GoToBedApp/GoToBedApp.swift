import SwiftUI
import AppKit
import GoToBedCore
import GoToBedKit

/// App entry point. A menu-bar-only (accessory) app: a `MenuBarExtra` for the
/// status item and a `Settings` scene for the schedule/appearance editors. The
/// overlay window is managed imperatively by `OverlayController`.
@main
struct GoToBedApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var env = AppEnvironment.shared

    var body: some Scene {
        MenuBarExtra("GoToBed", systemImage: "moon.zzz.fill") {
            MenuContent()
                .environmentObject(env)
        }
        .menuBarExtraStyle(.window)
    }
}

/// Owns process-level lifecycle: forces accessory (no Dock icon, FR-18) and
/// starts/stops the scheduler.
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        AppEnvironment.shared.start()

        // Discoverability: with no schedules yet, open settings so a first-time
        // user (or anyone who can't spot the menu-bar icon) sees the app.
        if AppEnvironment.shared.store.schedules.isEmpty {
            AppEnvironment.shared.openSettings()
        }
    }

    // Re-opening GoToBed (Spotlight/Finder) while it's already running — the
    // usual way back in when the menu-bar icon is hidden behind a crowded menu
    // bar — surfaces the settings window. macOS coalesces "open" of a running
    // app into this reopen event rather than launching a second process, so
    // this is the correct hook (instance-detection in didFinishLaunching never
    // fires for the normal reopen path).
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        Log.lifecycle.info("Reopen requested; opening settings.")
        AppEnvironment.shared.openSettings()
        return true
    }

    // A menu-bar app must NOT quit when its settings window closes — otherwise
    // closing settings (or the onboarding window) kills the whole app and the
    // menu-bar icon vanishes. Keep running; the user quits explicitly.
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationWillTerminate(_ notification: Notification) {
        AppEnvironment.shared.shutdown()
    }
}
