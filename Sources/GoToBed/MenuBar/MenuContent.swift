import SwiftUI
import GoToBedCore

/// The menu-bar popover: quick-toggle list of schedules plus the primary
/// actions (PRD §6, FR-19).
///
/// MenuContent reads only from `AppEnvironment` (the composition root) and
/// never touches `Store` directly. Domain data arrives pre-computed as
/// `[ScheduleDisplayItem]` via `env.scheduleItems`, so this view has no
/// direct domain dependency.
public struct MenuContent: View {
    public init() {}

    @EnvironmentObject private var env: AppEnvironment

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("GoToBed").font(.headline)
                Spacer()
                Text("v\(AppInfo.version)")
                    .font(.caption2).foregroundStyle(.secondary)
                    .accessibilityLabel("Version \(AppInfo.version)")
            }

            if env.scheduleItems.isEmpty {
                Text("No schedules yet.")
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            } else {
                ForEach(env.scheduleItems) { item in
                    ScheduleRow(item: item) { enabled in
                        env.setScheduleEnabled(enabled, id: item.id)
                    }
                }
            }

            Divider()

            Button("Add Schedule…") { env.addScheduleAndEdit() }
            Button("Settings…") { env.openSettings() }
            Button("Preview Overlay") { env.previewOverlay() }

            Toggle("Launch at Login", isOn: Binding(
                get: { env.launchAtLoginEnabled },
                set: { env.setLaunchAtLogin($0) }
            ))
            .toggleStyle(.checkbox)

            Divider()
            Button("Check for Updates…") { env.checkForUpdates() }
            Button("Quit GoToBed") { NSApp.terminate(nil) }
                .keyboardShortcut("q")
        }
        .padding(12)
        .frame(width: 280)
    }
}

/// A single schedule row with an inline enable toggle. Disabled schedules are
/// dimmed to read as visually distinct (FR-5).
///
/// Receives a `ScheduleDisplayItem` (plain value) and an `onToggle` callback
/// rather than observing Store directly.
private struct ScheduleRow: View {
    let item: ScheduleDisplayItem
    let onToggle: (Bool) -> Void

    var body: some View {
        HStack {
            Toggle("", isOn: Binding(
                get: { item.isEnabled },
                set: { onToggle($0) }
            ))
            .labelsHidden()
            .toggleStyle(.switch)
            .controlSize(.mini)

            VStack(alignment: .leading, spacing: 1) {
                Text(item.timeString)
                    .font(.system(.body, design: .rounded))
                    .monospacedDigit()
                Text(item.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
        }
        .opacity(item.isEnabled ? 1 : 0.45)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.timeString), \(item.isEnabled ? "enabled" : "disabled")")
    }
}
