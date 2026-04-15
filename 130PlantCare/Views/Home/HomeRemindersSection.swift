//
//  HomeRemindersSection.swift
//  130PlantCare
//

import SwiftUI

struct HomeRemindersSection: View {
    @ObservedObject var viewModel: PlantCareViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "bell.badge.fill")
                    .foregroundColor(.plantMuted)
                Text("Daily summary")
                    .font(.headline)
                    .foregroundColor(.plantSuccess)
                Spacer()
            }

            Toggle(isOn: Binding(
                get: { viewModel.reminderSetting.isEnabled },
                set: { newValue in
                    var s = viewModel.reminderSetting
                    s.isEnabled = newValue
                    viewModel.updateReminderSetting(s)
                }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Notification")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.plantSuccess)
                    Text("Daily count of pending tasks")
                        .font(.caption)
                        .foregroundColor(.plantMuted)
                }
            }
            .tint(.plantSuccess)

            HStack {
                Text("Time")
                    .font(.subheadline)
                    .foregroundColor(.plantMuted)
                Spacer()
                DatePicker(
                    "",
                    selection: Binding(
                        get: { viewModel.reminderSetting.time },
                        set: { newTime in
                            var s = viewModel.reminderSetting
                            s.time = newTime
                            viewModel.updateReminderSetting(s)
                        }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .labelsHidden()
                .tint(.plantSuccess)
                .disabled(!viewModel.reminderSetting.isEnabled)
            }
            .padding(.vertical, 4)
        }
        .padding(16)
        .homeCardBackground()
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 8, leading: HomeLayout.horizontalPadding, bottom: 8, trailing: HomeLayout.horizontalPadding))
    }
}
