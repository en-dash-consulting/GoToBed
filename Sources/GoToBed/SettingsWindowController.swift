import AppKit
import SwiftUI
import GoToBedCore

/// Manages the settings/editor window directly via AppKit.
///
/// A menu-bar-only (accessory) app cannot reliably open the SwiftUI `Settings`
/// scene through the `showSettingsWindow:` action selector, so we own a normal
/// `NSWindow` hosting `SettingsView` and bring it forward on demand. While it is
/// open the app is `.regular` (so it can take focus and show in the Dock); it
/// returns to `.accessory` on close unless an overlay is up.
///
/// This file lives alongside AppEnvironment.swift (the composition root) rather
/// than inside UI/ because window lifecycle is a composition-root concern:
/// AppEnvironment decides when to present or dismiss the window, and all
/// windowing decisions flow through it.
@MainActor
final class SettingsWindowController: NSObject, NSWindowDelegate {
    private var window: NSWindow?
    private let env: AppEnvironment

    init(env: AppEnvironment) {
        self.env = env
    }

    func show() {
        _ = NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        if let window {
            window.makeKeyAndOrderFront(nil)
            return
        }

        let root = SettingsView()
            .environmentObject(env)
            .environmentObject(env.store)
            .frame(minWidth: 760, minHeight: 560)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 640),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "GoToBed"
        window.contentView = NSHostingView(rootView: root)
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.center()
        window.makeKeyAndOrderFront(nil)
        self.window = window
        Log.lifecycle.info("Opened settings window.")
    }

    func windowWillClose(_ notification: Notification) {
        // Restore menu-bar-only state when settings closes (unless an overlay is
        // currently showing and already manages the policy).
        if !env.overlay.isShowing {
            _ = NSApp.setActivationPolicy(.accessory)
        }
    }
}
