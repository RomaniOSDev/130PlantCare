//
//  HomeView.swift
//  130PlantCare
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: PlantCareViewModel
    @State private var path: [UUID] = []
    @State private var showAddPlant = false

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    HomeHeaderSection(viewModel: viewModel)
                }

                Section {
                    HomeStatsStrip(viewModel: viewModel)
                }

                Section {
                    HomeSearchFiltersSection(viewModel: viewModel)
                }

                Section {
                    HomeCarePlanSection(viewModel: viewModel, path: $path)
                }

                Section {
                    HomeTodayTasksSection(viewModel: viewModel, path: $path)
                }

                Section {
                    HomeRemindersSection(viewModel: viewModel)
                }

                Section {
                    HomeSeasonalSection(viewModel: viewModel)
                }

                Section {
                    HomePlantsSection(viewModel: viewModel)
                } header: {
                    HStack {
                        Image(systemName: "leaf.arrow.circlepath")
                            .foregroundColor(.plantSuccess)
                        Text("My plants")
                            .font(.headline)
                            .foregroundColor(.plantSuccess)
                        Spacer()
                    }
                    .textCase(nil)
                    .padding(.leading, 4)
                    .listRowInsets(EdgeInsets(top: 0, leading: HomeLayout.horizontalPadding, bottom: 4, trailing: HomeLayout.horizontalPadding))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .plantScreenBackdrop()
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: UUID.self) { id in
                PlantDetailView(viewModel: viewModel, plantId: id)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddPlant = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Color.plantSuccess)
                    }
                    .accessibilityLabel("Add plant")
                }
            }
            .sheet(isPresented: $showAddPlant) {
                AddPlantView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    HomeViewPreviewHost()
}

private struct HomeViewPreviewHost: View {
    @StateObject private var viewModel = PlantCareViewModel()

    var body: some View {
        HomeView(viewModel: viewModel)
            .onAppear { viewModel.loadFromUserDefaults() }
    }
}
