//
//  HomeSearchFiltersSection.swift
//  130PlantCare
//

import SwiftUI

struct HomeSearchFiltersSection: View {
    @ObservedObject var viewModel: PlantCareViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    .foregroundColor(.plantSuccess)
                Text("Find & organize")
                    .font(.headline)
                    .foregroundColor(.plantSuccess)
                Spacer()
            }

            TextField("Search name, room, or tag", text: $viewModel.dashboardSearchText)
                .padding(12)
                .plantSoftLift(cornerRadius: 12)
                .tint(.plantSuccess)
                .foregroundColor(.plantSuccess)

            HStack {
                Text("Sort")
                    .font(.subheadline)
                    .foregroundColor(.plantMuted)
                Picker("Sort", selection: $viewModel.plantSortOrder) {
                    ForEach(PlantCareViewModel.PlantSortOrder.allCases) { order in
                        Text(order.rawValue).tag(order)
                    }
                }
                .pickerStyle(.menu)
                .tint(.plantSuccess)
                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    Menu {
                        Button("All rooms") {
                            viewModel.filterRoom = nil
                        }
                        ForEach(viewModel.uniqueRoomLocations, id: \.self) { room in
                            Button(room) {
                                viewModel.filterRoom = room
                            }
                        }
                    } label: {
                        filterMenuLabel(
                            title: "Room",
                            value: viewModel.filterRoom ?? "All"
                        )
                    }

                    Menu {
                        Button("All types") {
                            viewModel.filterPlantType = nil
                        }
                        ForEach(PlantType.allCases, id: \.self) { t in
                            Button("\(t.emoji) \(t.rawValue)") {
                                viewModel.filterPlantType = t
                            }
                        }
                    } label: {
                        filterMenuLabel(
                            title: "Type",
                            value: viewModel.filterPlantType?.rawValue ?? "All"
                        )
                    }
                }
            }

            HStack(spacing: 10) {
                FilterChip(title: "Favorites", isSelected: viewModel.filterFavoritesOnly, color: .plantSuccess)
                    .onTapGesture {
                        viewModel.filterFavoritesOnly.toggle()
                    }
                FilterChip(title: "Needs water", isSelected: viewModel.filterNeedsWaterOnly, color: .plantSuccess)
                    .onTapGesture {
                        viewModel.filterNeedsWaterOnly.toggle()
                    }
                if viewModel.hasActivePlantListFilters {
                    Button("Clear") {
                        viewModel.clearPlantListFilters()
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.plantSuccess)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background {
                        Capsule()
                            .fill(PlantDesign.cardGradient)
                            .overlay {
                                Capsule()
                                    .stroke(PlantDesign.cardBorderGradient(opacity: 0.28), lineWidth: 1)
                            }
                            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                    }
                }
            }
        }
        .padding(16)
        .homeCardBackground()
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 8, leading: HomeLayout.horizontalPadding, bottom: 8, trailing: HomeLayout.horizontalPadding))
    }

    private func filterMenuLabel(title: String, value: String) -> some View {
        HStack(spacing: 6) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.plantMuted)
                Text(value)
                    .font(.caption)
                    .foregroundColor(.plantSuccess)
                    .lineLimit(1)
            }
            Image(systemName: "chevron.down")
                .font(.caption2)
                .foregroundColor(.plantMuted)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .plantSoftLift(cornerRadius: 10)
    }
}
