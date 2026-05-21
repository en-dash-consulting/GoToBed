import SwiftUI
import GoToBedCore

/// The settings window: a Schedules tab (list + editor) and a Default
/// Appearance tab (PRD §6).
struct SettingsView: View {
    var body: some View {
        TabView {
            SchedulesPane()
                .tabItem { Label("Schedules", systemImage: "list.bullet") }
            DefaultAppearancePane()
                .tabItem { Label("Default Appearance", systemImage: "paintpalette") }
        }
        .padding()
    }
}

/// Master/detail: schedule list on the left, editor on the right.
private struct SchedulesPane: View {
    @EnvironmentObject private var env: AppEnvironment
    @EnvironmentObject private var store: Store
    @State private var selection: UUID?

    var body: some View {
        HSplitView {
            VStack(spacing: 0) {
                List(selection: $selection) {
                    ForEach(store.schedules) { schedule in
                        VStack(alignment: .leading) {
                            Text(ScheduleFormatting.timeString(schedule))
                                .monospacedDigit()
                                .opacity(schedule.isEnabled ? 1 : 0.45)
                            Text(ScheduleFormatting.daysSummary(schedule.weekdays))
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        .tag(schedule.id)
                    }
                }
                HStack {
                    Button(action: addSchedule) { Image(systemName: "plus") }
                        .help("Add schedule")
                    Button(action: deleteSelected) { Image(systemName: "minus") }
                        .help("Delete schedule")
                        .disabled(selection == nil)
                    Spacer()
                }
                .padding(6)
            }
            .frame(minWidth: 220)

            Group {
                if let id = selection, let schedule = store.schedule(id: id) {
                    ScheduleEditorView(schedule: schedule)
                        .id(id)
                } else {
                    Text("Select or add a schedule")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(minWidth: 500)
        }
    }

    private func addSchedule() {
        let new = store.makeSchedule(
            hour: 22, minute: 30, weekdays: WeekdayPreset.everyDay,
            message: "Time to wind down. Go to bed."
        )
        store.add(new)
        selection = new.id
    }

    private func deleteSelected() {
        guard let id = selection else { return }
        store.delete(id: id)
        selection = store.schedules.first?.id
    }
}

private struct DefaultAppearancePane: View {
    @EnvironmentObject private var store: Store
    @State private var draft: AppearanceSettings = .appDefault

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("New schedules start from these settings. Editing them does not change existing schedules.")
                .font(.callout)
                .foregroundStyle(.secondary)
            AppearanceEditor(appearance: $draft)
            Spacer()
        }
        .onAppear { draft = store.defaultAppearance }
        .onChangeCompat(of: draft) { new in store.updateDefaultAppearance(new) }
    }
}
