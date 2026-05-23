import SwiftUI
import GoToBedCore

/// The menu-bar popover: quick-toggle list of schedules plus the primary
/// actions (PRD §6, FR-19).
struct MenuContent: View {
    @EnvironmentObject private var env: AppEnvironment
    @EnvironmentObject private var store: Store

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("GoToBed").font(.headline)
                Spacer()
                Text("v\(AppInfo.version)")
                    .font(.caption2).foregroundStyle(.secondary)
                    .accessibilityLabel("Version \(AppInfo.version)")
            }

            if store.schedules.isEmpty {
                Text("No schedules yet.")
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            } else {
                ForEach(store.schedules) { schedule in
                    ScheduleRow(schedule: schedule)
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
private struct ScheduleRow: View {
    @EnvironmentObject private var store: Store
    let schedule: Schedule

    var body: some View {
        HStack {
            Toggle("", isOn: Binding(
                get: { schedule.isEnabled },
                set: { store.setEnabled($0, id: schedule.id) }
            ))
            .labelsHidden()
            .toggleStyle(.switch)
            .controlSize(.mini)

            VStack(alignment: .leading, spacing: 1) {
                Text(ScheduleFormatting.timeString(schedule))
                    .font(.system(.body, design: .rounded))
                    .monospacedDigit()
                Text(ScheduleFormatting.daysAndMessage(schedule))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
        }
        .opacity(schedule.isEnabled ? 1 : 0.45)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(ScheduleFormatting.timeString(schedule)), \(schedule.isEnabled ? "enabled" : "disabled")")
    }
}
