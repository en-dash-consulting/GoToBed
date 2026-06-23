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
    private let challenge: DismissChallengeState

    init(schedule: Schedule, screen: NSScreen, reduceMotion: Bool, onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
        self.challenge = DismissChallengeState(challenge: schedule.dismissChallenge)
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
            challenge: challenge,
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

    /// Esc (and the standard cancel action) dismisses immediately when the
    /// schedule uses the default escape challenge (FR-8). The friction challenges
    /// (random key / type phrase) deliberately ignore Esc — Cmd-Tab/force-quit
    /// remain the always-available OS escape routes.
    override func cancelOperation(_ sender: Any?) {
        if challenge.escDismisses { requestDismiss() }
    }

    override func keyDown(with event: NSEvent) {
        // Esc keyCode is 53; honored only by the escape challenge.
        if event.keyCode == 53 {
            if challenge.escDismisses { requestDismiss() }
            return
        }

        // Backspace (keyCode 51) edits the type-to-dismiss buffer.
        if event.keyCode == 51 {
            challenge.deleteBackward()
            return
        }

        // Feed printable characters to the challenge; dismiss once satisfied.
        if let chars = event.charactersIgnoringModifiers, !chars.isEmpty {
            var satisfied = false
            for ch in chars where !satisfied {
                satisfied = challenge.handle(character: ch)
            }
            if satisfied {
                requestDismiss()
                return
            }
            // A challenge consumed the keystroke — don't beep via super.
            if challenge.escDismisses == false { return }
        }

        super.keyDown(with: event)
    }

    private var dismissing = false
    private func requestDismiss() {
        guard !dismissing else { return }
        dismissing = true
        onDismiss()
    }
}
