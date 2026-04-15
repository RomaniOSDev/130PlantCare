//
//  HistoryCard.swift
//  130PlantCare
//

import SwiftUI

struct HistoryCard: View {
    let record: PlantCareViewModel.HistoryRecord

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(PlantDesign.iconTileGradient)
                    .frame(width: 44, height: 44)
                    .shadow(color: Color.plantSuccess.opacity(0.2), radius: 6, x: 0, y: 3)
                Image(systemName: record.icon)
                    .foregroundColor(.plantSuccess)
                    .font(.title3)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(record.plantName)
                    .font(.headline)
                    .foregroundColor(.plantSuccess)
                Text(record.title)
                    .font(.caption)
                    .foregroundColor(.plantMuted)
                Text(formattedDate(record.date))
                    .font(.caption2)
                    .foregroundColor(.plantMuted.opacity(0.85))
            }
            Spacer()
            if let notes = record.notes, !notes.isEmpty {
                Image(systemName: "note.text")
                    .foregroundColor(.plantMuted)
                    .font(.caption)
            }
        }
        .padding(14)
        .plantSoftLift(cornerRadius: 16)
    }
}
