//
//  HomeTodayTasksSection.swift
//  130PlantCare
//

import SwiftUI

struct HomeTodayTasksSection: View {
    @ObservedObject var viewModel: PlantCareViewModel
    @Binding var path: [UUID]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checklist")
                    .foregroundColor(.plantSuccess)
                Text("Due today")
                    .font(.headline)
                    .foregroundColor(.plantSuccess)
                Spacer()
                if !viewModel.todayTasks.isEmpty {
                    Text("\(viewModel.todayTasks.count)")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background {
                            Capsule()
                                .fill(PlantDesign.primaryButtonGradient)
                                .shadow(color: Color.plantSuccess.opacity(0.4), radius: 6, x: 0, y: 3)
                        }
                }
            }

            if viewModel.todayTasks.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.plantSuccess)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("You are all set")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.plantSuccess)
                        Text("No care tasks waiting right now.")
                            .font(.caption)
                            .foregroundColor(.plantMuted)
                    }
                    Spacer(minLength: 0)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(PlantDesign.insetPanelGradient)
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(PlantDesign.cardBorderGradient(opacity: 0.15), lineWidth: 1)
                        }
                        .shadow(color: Color.plantSuccess.opacity(0.12), radius: 10, x: 0, y: 4)
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.todayTasks) { task in
                            TaskCard(task: task, onComplete: {
                                viewModel.completeTask(task)
                            }, onSelectPlant: {
                                path.append(task.plantId)
                            })
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(16)
        .homeCardBackground()
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 8, leading: HomeLayout.horizontalPadding, bottom: 8, trailing: HomeLayout.horizontalPadding))
    }
}
