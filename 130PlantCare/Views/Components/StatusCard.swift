//
//  StatusCard.swift
//  130PlantCare
//

import SwiftUI

struct StatusCard: View {
    let title: String
    let status: String
    let nextDate: Date?
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(PlantDesign.iconTileGradient)
                    .frame(width: 44, height: 44)
                    .shadow(color: color.opacity(0.22), radius: 8, x: 0, y: 4)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3.weight(.semibold))
            }
            Text(title)
                .font(.caption)
                .foregroundColor(.plantMuted)
            Text(status)
                .font(.caption)
                .foregroundColor(color)
                .bold()
                .multilineTextAlignment(.center)
            if let date = nextDate {
                Text(formattedShortDate(date))
                    .font(.caption2)
                    .foregroundColor(.plantMuted)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .plantElevatedCard(cornerRadius: 16)
    }
}
