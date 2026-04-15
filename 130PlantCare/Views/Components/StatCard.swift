//
//  StatCard.swift
//  130PlantCare
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(PlantDesign.iconTileGradient)
                        .frame(width: 36, height: 36)
                        .shadow(color: color.opacity(0.25), radius: 6, x: 0, y: 3)
                    Image(systemName: icon)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(color)
                }
                Text(title)
                    .foregroundColor(.plantMuted)
                    .font(.caption)
            }
            Text(value)
                .foregroundStyle(PlantDesign.titleForeground)
                .font(.title2)
                .bold()
        }
        .padding(14)
        .frame(minWidth: 140, alignment: .leading)
        .plantElevatedCard(cornerRadius: 14)
    }
}
