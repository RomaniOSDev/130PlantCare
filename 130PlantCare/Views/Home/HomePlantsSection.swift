//
//  HomePlantsSection.swift
//  130PlantCare
//

import SwiftUI

struct HomePlantsSection: View {
    @ObservedObject var viewModel: PlantCareViewModel

    var body: some View {
        ForEach(viewModel.filteredSortedPlants) { plant in
            NavigationLink(value: plant.id) {
                PlantRow(plant: plant)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 6, leading: HomeLayout.horizontalPadding, bottom: 6, trailing: HomeLayout.horizontalPadding))
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    viewModel.deletePlant(plant)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                Button {
                    viewModel.waterPlant(plant)
                } label: {
                    Label("Water", systemImage: "drop.fill")
                }
                .tint(.plantSuccess)
            }
        }
    }
}
