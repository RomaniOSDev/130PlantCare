//
//  PlantRow.swift
//  130PlantCare
//

import SwiftUI

struct PlantRow: View {
    let plant: Plant

    var body: some View {
        HStack {
            Text(plant.type.emoji)
                .font(.title2)
                .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
            VStack(alignment: .leading, spacing: 4) {
                Text(plant.name)
                    .font(.headline)
                    .foregroundColor(.plantSuccess)
                Text(plant.location)
                    .font(.caption)
                    .foregroundColor(.plantMuted)
                if !plant.tagList.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(plant.tagList, id: \.self) { tag in
                            Image(systemName: tag.icon)
                                .font(.caption2)
                                .foregroundColor(.plantMuted)
                                .accessibilityLabel(tag.rawValue)
                        }
                    }
                }
            }
            Spacer()
            if plant.needsWatering {
                Image(systemName: "drop.fill")
                    .foregroundColor(.plantSuccess)
                    .font(.caption)
                    .shadow(color: Color.plantSuccess.opacity(0.35), radius: 4, x: 0, y: 1)
            }
            if plant.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundColor(.plantSuccess)
                    .font(.caption)
                    .shadow(color: Color.plantSuccess.opacity(0.3), radius: 3, x: 0, y: 1)
            }
            Image(systemName: "chevron.right")
                .foregroundColor(.plantMuted)
                .font(.caption.weight(.semibold))
        }
        .padding(14)
        .plantSoftLift(cornerRadius: 14)
    }
}
