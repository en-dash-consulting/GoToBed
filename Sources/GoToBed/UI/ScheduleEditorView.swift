import SwiftUI
import GoToBedCore

/// Editor for a single schedule. Edits a local draft and writes sanitized
/// changes back through AppEnvironment (the composition root).
///
/// Writing through `env.updateSchedule(_:)` rather than `store.update(_:)` keeps
/// the settings-ui zone free of direct Store write dependencies (PRD §3.1, §6).
struct ScheduleEditorView: View {
    @EnvironmentObject private var env: AppEnvironment

    @State private var draft: Schedule
    /// Remembered auto duration so toggling Manual -> Auto restores the value.
    @State private var autoSeconds: Int

    init(schedule: Schedule) {
        _draft = State(initialValue: schedule)
        _autoSeconds = State(initialValue: schedule.dismissMode.autoSeconds ?? DismissMode.defaultAutoSeconds)
    }

    var body: some View {
        Form {
            Section {
                Toggle("Enabled", isOn: $draft.isEnabled)
                DatePicker("Time", selection: timeBinding, displayedComponents: .hourAndMinute)
            }

            Section("Active days") {
                WeekdayPicker(weekdays: $draft.weekdays)
                if draft.weekdays.isEmpty {
                    Label("Select at least one day.", systemImage: "exclamationmark.triangle")
                        .font(.caption).foregroundStyle(.orange)
                }
            }

            Section("Message") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Primary").font(.caption).foregroundStyle(.secondary)
                    TextEditor(text: $draft.message)
                        .frame(minHeight: 54)
                        .font(.body)
                    Text("\(draft.message.count)/\(Schedule.maxMessageLength)")
                        .font(.caption2).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Submessage (optional)").font(.caption).foregroundStyle(.secondary)
                    TextEditor(text: $draft.submessage)
                        .frame(minHeight: 40)
                        .font(.body)
                    Text("\(draft.submessage.count)/\(Schedule.maxMessageLength)")
                        .font(.caption2).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }

            Section("Dismissal") {
                Picker("When shown", selection: isAutoBinding) {
                    Text("Auto-dismiss").tag(true)
                    Text("Manual (Esc)").tag(false)
                }
                .pickerStyle(.segmented)

                if draft.dismissMode.autoSeconds != nil {
                    Stepper(value: autoSecondsBinding, in: Schedule.durationRange, step: 5) {
                        Text("Duration: \(autoSeconds)s")
                    }
                }
            }

            Section("Appearance") {
                AppearanceEditor(appearance: $draft.appearance)
            }

            Section {
                Button("Preview Overlay") { env.previewOverlay(draft) }
            }
        }
        .formStyle(.grouped)
        // Persist (sanitized) on any change through the composition-root coordinator.
        .onChangeCompat(of: draft) { newValue in env.updateSchedule(newValue) }
    }

    // MARK: Bindings

    private var timeBinding: Binding<Date> {
        Binding(
            get: {
                var c = DateComponents(); c.hour = draft.hour; c.minute = draft.minute
                return Calendar.current.date(from: c) ?? Date()
            },
            set: { newDate in
                let c = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                draft.hour = c.hour ?? draft.hour
                draft.minute = c.minute ?? draft.minute
            }
        )
    }

    private var isAutoBinding: Binding<Bool> {
        Binding(
            get: { draft.dismissMode.autoSeconds != nil },
            set: { isAuto in
                draft.dismissMode = isAuto ? .auto(seconds: autoSeconds) : .manual
            }
        )
    }

    private var autoSecondsBinding: Binding<Int> {
        Binding(
            get: { autoSeconds },
            set: { newValue in
                autoSeconds = newValue
                draft.dismissMode = .auto(seconds: newValue)
            }
        )
    }
}
