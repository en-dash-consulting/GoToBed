import AppKit
import SwiftUI
import GoToBedCore

/// Owns the single active overlay window and its dismissal lifecycle.
///
/// Enforces FR-9/FR-16: only one overlay is ever visible; a new fire replaces
/// the current one immediately (newer message wins) rather than stacking.
@MainActor
final class OverlayController {
    private var window: OverlayWindow?
    private var autoDismissTimer: Timer?
    private var previousActivationPolicy: NSApplication.ActivationPolicy?

    /// Whether an overlay is currently on screen.
    var isShowing: Bool { window != nil }

    /// Present `schedule`'s overlay on the active screen, replacing any current
    /// overlay (FR-16). Honors Reduce Motion by skipping the fade (NFR-a11y-2).
    func present(_ schedule: Schedule) {
        // Replace any existing overlay immediately — newer message wins.
        teardown(animated: false)

        let screen = NSScreen.main ?? NSScreen.screens.first
        guard let screen else {
            Log.overlay.error("No screen available to present overlay.")
            return
        }

        let reduceMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        let window = OverlayWindow(
            schedule: schedule,
            screen: screen,
            reduceMotion: reduceMotion,
            onDismiss: { [weak self] in self?.dismiss() }
        )

        // Temporarily become a regular app so the borderless window can take key
        // focus to receive the Esc keypress, then restore accessory (menu-bar)
        // policy on dismiss so the Dock icon never lingers (FR-18).
        previousActivationPolicy = NSApp.activationPolicy()
        _ = NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        window.alphaValue = reduceMotion ? 1.0 : 0.0
        window.makeKeyAndOrderFront(nil)
        if !reduceMotion {
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.25 // ≤300ms fade (NFR-perf-2)
                window.animator().alphaValue = 1.0
            }
        }
        self.window = window

        if let seconds = schedule.dismissMode.autoSeconds {
            let timer = Timer(timeInterval: TimeInterval(seconds), repeats: false) { [weak self] _ in
                Task { @MainActor in self?.dismiss() }
            }
            RunLoop.main.add(timer, forMode: .common)
            autoDismissTimer = timer
        }

        Log.overlay.info("Presented overlay (mode: \(String(describing: schedule.dismissMode), privacy: .public)).")
    }

    /// Dismiss the current overlay (fade out unless Reduce Motion is set).
    func dismiss() {
        guard window != nil else { return }
        Log.overlay.info("Overlay dismissed.")
        let reduceMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        teardown(animated: !reduceMotion)
    }

    private func teardown(animated: Bool) {
        autoDismissTimer?.invalidate()
        autoDismissTimer = nil
        guard let window else { return }
        self.window = nil

        let restore = { [previousActivationPolicy] in
            // Restore menu-bar-only state; never leave a Dock icon behind.
            _ = NSApp.setActivationPolicy(previousActivationPolicy ?? .accessory)
        }

        if animated {
            NSAnimationContext.runAnimationGroup({ ctx in
                ctx.duration = 0.2
                window.animator().alphaValue = 0.0
            }, completionHandler: {
                window.orderOut(nil)
                restore()
            })
        } else {
            window.orderOut(nil)
            restore()
        }
    }
}
