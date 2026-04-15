//
//  StatsView.swift
//  130PlantCare
//

import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: PlantCareViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Statistics")
                            .font(.largeTitle)
                            .bold()
                            .foregroundStyle(PlantDesign.titleForeground)
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(PlantDesign.accentUnderlineGradient)
                            .frame(width: 56, height: 4)
                            .shadow(color: Color.plantSuccess.opacity(0.35), radius: 4, x: 0, y: 2)
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        StatCard(
                            title: "Plants",
                            value: "\(viewModel.plants.count)",
                            icon: "leaf.fill",
                            color: .plantSuccess
                        )
                        StatCard(
                            title: "Waterings",
                            value: "\(viewModel.totalWaterings)",
                            icon: "drop.fill",
                            color: .plantSuccess
                        )
                        StatCard(
                            title: "Fertilizings",
                            value: "\(viewModel.totalFertilizings)",
                            icon: "leaf.fill",
                            color: .plantSuccess
                        )
                        StatCard(
                            title: "Repottings",
                            value: "\(viewModel.totalRepottings)",
                            icon: "arrow.2.circlepath",
                            color: .plantSuccess
                        )
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Plant types")
                            .font(.headline)
                            .foregroundColor(.plantSuccess)
                        ForEach(viewModel.typeDistribution) { item in
                            HStack {
                                Text(item.emoji)
                                    .font(.title3)
                                Text(item.name)
                                    .foregroundColor(.plantSuccess)
                                Spacer()
                                Text("\(item.count)")
                                    .foregroundColor(.plantSuccess)
                                    .bold()
                                Text("plants")
                                    .font(.caption)
                                    .foregroundColor(.plantMuted)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .plantElevatedCard(cornerRadius: PlantDesign.radiusCard)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Watering frequency")
                            .font(.headline)
                            .foregroundColor(.plantSuccess)
                        ForEach(viewModel.wateringFrequency) { item in
                            HStack {
                                Text(item.frequency.rawValue)
                                    .foregroundColor(.plantSuccess)
                                Spacer()
                                Text("\(item.count) plants")
                                    .foregroundColor(.plantMuted)
                                    .font(.caption)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .plantElevatedCard(cornerRadius: PlantDesign.radiusCard)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .plantScreenBackdrop()
        }
    }
}
