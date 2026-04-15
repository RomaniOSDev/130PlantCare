//
//  HistoryRow.swift
//  130PlantCare
//

import SwiftUI

struct HistoryRow: View {
    let title: String
    let date: Date
    let notes: String?
    let color: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(color)
                Text(formattedDateTime(date))
                    .font(.caption)
                    .foregroundColor(.plantMuted)
            }
            Spacer()
            if let notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.plantMuted)
                    .lineLimit(1)
            }
        }
        .padding(12)
        .plantSoftLift(cornerRadius: 12)
        .padding(.horizontal)
    }
}
