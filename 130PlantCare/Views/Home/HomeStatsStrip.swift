//
//  HomeStatsStrip.swift
//  130PlantCare
//

import SwiftUI

struct HomeStatsStrip: View {
    @ObservedObject var viewModel: PlantCareViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("At a glance")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.plantMuted)
                .textCase(.uppercase)
                .tracking(0.6)
                .padding(.horizontal, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    StatCard(
                        title: "Plants",
                        value: "\(viewModel.plants.count)",
                        icon: "leaf.fill",
                        color: .plantSuccess
                    )
                    StatCard(
                        title: "Need water",
                        value: "\(viewModel.plantsNeedingWater)",
                        icon: "drop.fill",
                        color: .plantSuccess
                    )
                    StatCard(
                        title: "Healthy",
                        value: "\(viewModel.healthyPlants)",
                        icon: "checkmark.circle.fill",
                        color: .plantSuccess
                    )
                    StatCard(
                        title: "Tasks",
                        value: "\(viewModel.upcomingTasks)",
                        icon: "bell.fill",
                        color: .plantMuted
                    )
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 2)
            }
        }
        .listRowInsets(EdgeInsets(top: 4, leading: HomeLayout.horizontalPadding, bottom: 8, trailing: HomeLayout.horizontalPadding))
        .listRowBackground(Color.clear)
    }
}
