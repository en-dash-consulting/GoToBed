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
    /// Remembered phrase so switching challenge modes preserves what was typed.
    @State private var typePhrase: String

    /// Which dismissal action the overlay requires — the picker's tag type.
    private enum ChallengeKind: Hashable { case escape, randomKey, typeString }

    init(schedule: Schedule) {
        _draft = State(initialValue: schedule)
        _autoSeconds = State(initialValue: schedule.dismissMode.autoSeconds ?? DismissMode.defaultAutoSeconds)
        if case let .typeString(phrase) = schedule.dismissChallenge, !phrase.isEmpty {
            _typePhrase = State(initialValue: phrase)
        } else {
            _typePhrase = State(initialValue: "go to bed")
        }
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

                Picker("To dismiss", selection: challengeKindBinding) {
                    Text("Press Esc").tag(ChallengeKind.escape)
                    Text("Press a random key").tag(ChallengeKind.randomKey)
                    Text("Type a phrase").tag(ChallengeKind.typeString)
                }

                if case .typeString = draft.dismissChallenge {
                    TextField("Phrase to type", text: typePhraseBinding)
                        .textFieldStyle(.roundedBorder)
                    if typePhrase.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Label("Enter a phrase, or it falls back to Esc.", systemImage: "exclamationmark.triangle")
                            .font(.caption).foregroundStyle(.orange)
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

    private var challengeKindBinding: Binding<ChallengeKind> {
        Binding(
            get: {
                switch draft.dismissChallenge {
                case .escape:     return .escape
                case .randomKey:  return .randomKey
                case .typeString: return .typeString
                }
            },
            set: { kind in
                switch kind {
                case .escape:     draft.dismissChallenge = .escape
                case .randomKey:  draft.dismissChallenge = .randomKey
                case .typeString: draft.dismissChallenge = .typeString(typePhrase)
                }
            }
        )
    }

    private var typePhraseBinding: Binding<String> {
        Binding(
            get: { typePhrase },
            set: { newValue in
                typePhrase = newValue
                draft.dismissChallenge = .typeString(newValue)
            }
        )
    }
}
