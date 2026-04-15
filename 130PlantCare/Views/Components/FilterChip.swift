//
//  FilterChip.swift
//  130PlantCare
//

import SwiftUI

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color

    var body: some View {
        Text(title)
            .font(.subheadline.weight(isSelected ? .semibold : .regular))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background {
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: PlantDesign.radiusChip, style: .continuous)
                            .fill(PlantDesign.primaryButtonGradient)
                            .shadow(color: Color.plantSuccess.opacity(0.4), radius: 8, x: 0, y: 4)
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                    } else {
                        RoundedRectangle(cornerRadius: PlantDesign.radiusChip, style: .continuous)
                            .fill(PlantDesign.cardGradient)
                            .overlay {
                                RoundedRectangle(cornerRadius: PlantDesign.radiusChip, style: .continuous)
                                    .stroke(PlantDesign.cardBorderGradient(opacity: 0.2), lineWidth: 1)
                            }
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            .shadow(color: Color.plantSuccess.opacity(0.08), radius: 8, x: 0, y: 4)
                    }
                }
            }
            .foregroundColor(isSelected ? .white : color)
    }
}
