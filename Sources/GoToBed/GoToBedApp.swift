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
    /// Broadcast (cross-process) ping telling the running instance to surface
    /// its settings window.
    static let showSettings = Notification.Name("us.endash.GoToBed.showSettings")

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        // If GoToBed is already running and the user opened it again — typically
        // because the menu-bar icon is hidden behind a crowded menu bar — hand
        // off to the existing instance (open its settings) and exit, so
        // re-launching is a reliable way back into the app.
        if let bundleID = Bundle.main.bundleIdentifier {
            let me = NSRunningApplication.current.processIdentifier
            let alreadyRunning = NSWorkspace.shared.runningApplications.contains {
                $0.bundleIdentifier == bundleID && $0.processIdentifier != me
            }
            if alreadyRunning {
                DistributedNotificationCenter.default().postNotificationName(
                    Self.showSettings, object: nil, userInfo: nil, deliverImmediately: true)
                Log.lifecycle.info("Another instance is running; asked it to open settings and exiting.")
                NSApp.terminate(nil)
                return
            }
        }

        // Primary instance: surface settings whenever a relaunch pings us.
        DistributedNotificationCenter.default().addObserver(
            forName: Self.showSettings, object: nil, queue: .main
        ) { _ in
            MainActor.assumeIsolated { AppEnvironment.shared.openSettings() }
        }

        AppEnvironment.shared.start()

        // Discoverability: with no schedules yet, open settings so a first-time
        // user (or anyone who can't spot the menu-bar icon) sees the app.
        if AppEnvironment.shared.store.schedules.isEmpty {
            AppEnvironment.shared.openSettings()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        AppEnvironment.shared.shutdown()
    }
}
