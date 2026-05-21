import SwiftUI
import AppKit
import GoToBedCore

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
                .environmentObject(env.store)
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
    }

    func applicationWillTerminate(_ notification: Notification) {
        AppEnvironment.shared.shutdown()
    }
}
