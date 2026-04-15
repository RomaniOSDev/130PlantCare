//
//  HomeHeaderSection.swift
//  130PlantCare
//

import SwiftUI

struct HomeHeaderSection: View {
    @ObservedObject var viewModel: PlantCareViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(PlantDesign.iconTileGradient)
                    .frame(width: 56, height: 56)
                    .shadow(color: Color.plantSuccess.opacity(0.28), radius: 12, x: 0, y: 6)
                Image(systemName: "leaf.fill")
                    .font(.title2)
                    .foregroundColor(.plantSuccess)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("Good to see you")
                    .font(.subheadline)
                    .foregroundColor(.plantMuted)
                Text("Home")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(PlantDesign.titleForeground)
                overviewSubtitle
                    .font(.subheadline)
                    .foregroundColor(.plantMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 8, leading: HomeLayout.horizontalPadding, bottom: 4, trailing: HomeLayout.horizontalPadding))
    }

    private var overviewSubtitle: Text {
        let total = viewModel.plants.count
        let shown = viewModel.filteredSortedPlants.count
        if shown < total {
            return Text("Showing \(shown) of \(total) plants · \(viewModel.upcomingTasks) open tasks")
        }
        return Text("\(total) plants · \(viewModel.upcomingTasks) open tasks")
    }
}
