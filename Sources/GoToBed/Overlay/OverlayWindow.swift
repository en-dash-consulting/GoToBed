import AppKit
import SwiftUI
import GoToBedCore

/// A borderless, full-screen "soft overlay" window (PRD §5.4).
///
/// It draws above the menu bar and Dock (shielding window level) and across
/// spaces, but is intentionally NOT a kiosk lock: it never captures the event
/// tap or hides the menu bar globally, so `Esc`, `Cmd-Tab`, Mission Control,
/// and force-quit all keep working (FR-8).
final class OverlayWindow: NSWindow {
    private let onDismiss: () -> Void

    init(schedule: Schedule, screen: NSScreen, reduceMotion: Bool, onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        level = NSWindow.Level(rawValue: Int(CGShieldingWindowLevel()))
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        ignoresMouseEvents = false
        isReleasedWhenClosed = false
        // Show above fullscreen apps without stealing permanent menu-bar state.
        animationBehavior = .none

        let root = OverlayView(
            schedule: schedule,
            startDate: Date(),
            onDismiss: { [weak self] in self?.requestDismiss() }
        )
        let hosting = NSHostingView(rootView: root)
        hosting.frame = screen.frame
        hosting.autoresizingMask = [.width, .height]
        contentView = hosting

        setFrame(screen.frame, display: true)
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    /// Esc (and the standard cancel action) dismisses immediately (FR-8).
    override func cancelOperation(_ sender: Any?) {
        requestDismiss()
    }

    override func keyDown(with event: NSEvent) {
        // Esc keyCode is 53; also honor the cancel selector path.
        if event.keyCode == 53 {
            requestDismiss()
        } else {
            super.keyDown(with: event)
        }
    }

    private var dismissing = false
    private func requestDismiss() {
        guard !dismissing else { return }
        dismissing = true
        onDismiss()
    }
}
