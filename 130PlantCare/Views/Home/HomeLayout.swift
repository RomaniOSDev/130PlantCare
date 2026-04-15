//
//  HomeLayout.swift
//  130PlantCare
//

import SwiftUI

enum HomeLayout {
    static let cardCorner: CGFloat = PlantDesign.radiusCard
    static let horizontalPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 12
}

extension View {
    func homeCardBackground() -> some View {
        plantElevatedCard(cornerRadius: HomeLayout.cardCorner)
    }
}
