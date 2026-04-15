//
//  PlantDesign.swift
//  130PlantCare
//

import SwiftUI

enum PlantDesign {
    static let radiusCard: CGFloat = 16
    static let radiusControl: CGFloat = 12
    static let radiusChip: CGFloat = 20

    /// Full screen: light depth from white into a soft botanical tint.
    static var screenGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white,
                Color(red: 0.96, green: 0.99, blue: 0.97),
                Color.plantSuccess.opacity(0.09)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// Raised cards: subtle cool-white to mint-white.
    static var cardGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white,
                Color(red: 0.97, green: 0.995, blue: 0.98)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Inset panels (plan day, secondary blocks).
    static var insetPanelGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.plantSuccess.opacity(0.06),
                Color.plantSuccess.opacity(0.02)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var primaryButtonGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.02, green: 0.38, blue: 0.07),
                Color.plantSuccess
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var secondaryButtonGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.40, green: 0.52, blue: 0.49),
                Color.plantMuted
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var iconTileGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.plantSuccess.opacity(0.22),
                Color.plantSuccess.opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var accentUnderlineGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.plantSuccess,
                Color.plantSuccess.opacity(0.35)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    /// Title text: depth without heavy color blocks.
    static var titleForeground: LinearGradient {
        LinearGradient(
            colors: [
                Color.plantSuccess,
                Color(red: 0.02, green: 0.26, blue: 0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func cardBorderGradient(opacity: Double = 0.2) -> LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.95),
                Color.plantSuccess.opacity(opacity)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension View {
    /// Standard app backdrop behind scrollable content.
    func plantScreenBackdrop() -> some View {
        background {
            PlantDesign.screenGradient
                .ignoresSafeArea()
        }
    }

    /// Elevated card: gradient fill, rim light, stacked shadows for volume.
    func plantElevatedCard(cornerRadius: CGFloat = PlantDesign.radiusCard) -> some View {
        background {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(PlantDesign.cardGradient)
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(PlantDesign.cardBorderGradient(opacity: 0.18), lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 2)
            .shadow(color: Color.plantSuccess.opacity(0.16), radius: 14, x: 0, y: 7)
            .shadow(color: Color.black.opacity(0.05), radius: 26, x: 0, y: 16)
        }
    }

    /// Softer lift for list rows and compact tiles.
    func plantSoftLift(cornerRadius: CGFloat = PlantDesign.radiusControl) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(PlantDesign.cardGradient)
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(PlantDesign.cardBorderGradient(opacity: 0.12), lineWidth: 1)
                }
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                .shadow(color: Color.plantSuccess.opacity(0.10), radius: 10, x: 0, y: 5)
        }
    }

    func plantPrimaryPill(cornerRadius: CGFloat = PlantDesign.radiusControl) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(PlantDesign.primaryButtonGradient)
                .shadow(color: Color.plantSuccess.opacity(0.45), radius: 8, x: 0, y: 4)
                .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
        }
    }

    func plantSecondaryPill(cornerRadius: CGFloat = PlantDesign.radiusControl) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(PlantDesign.secondaryButtonGradient)
                .shadow(color: Color.plantMuted.opacity(0.35), radius: 8, x: 0, y: 4)
                .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 2)
        }
    }
}
