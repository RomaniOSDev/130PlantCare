//
//  TaskCard.swift
//  130PlantCare
//

import SwiftUI

struct TaskCard: View {
    let task: PlantCareViewModel.TodayTask
    let onComplete: () -> Void
    var onSelectPlant: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: task.icon)
                    .foregroundColor(.plantSuccess)
                    .font(.title2)
                    .shadow(color: Color.plantSuccess.opacity(0.25), radius: 4, x: 0, y: 2)
                Text(task.plantName)
                    .font(.headline)
                    .foregroundColor(.plantSuccess)
                    .lineLimit(1)
                Spacer()
                if task.isUrgent {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.plantSuccess)
                        .font(.caption)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onSelectPlant?()
            }
            Text(task.title)
                .font(.caption)
                .foregroundColor(.plantMuted)
                .onTapGesture {
                    onSelectPlant?()
                }
            Button(action: onComplete) {
                Text("Done")
                    .font(.caption.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .foregroundColor(.white)
                    .plantPrimaryPill(cornerRadius: 10)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .frame(width: 168)
        .plantElevatedCard(cornerRadius: 16)
    }
}
