//
//  HistoryView.swift
//  130PlantCare
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: PlantCareViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Care history")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(PlantDesign.titleForeground)
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(PlantDesign.accentUnderlineGradient)
                        .frame(width: 48, height: 4)
                        .shadow(color: Color.plantSuccess.opacity(0.3), radius: 4, x: 0, y: 2)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            FilterChip(title: "All", isSelected: viewModel.selectedFilter == nil, color: .plantSuccess)
                                .onTapGesture { viewModel.selectedFilter = nil }
                            FilterChip(title: "Watering", isSelected: viewModel.selectedFilter == .watering, color: .plantSuccess)
                                .onTapGesture { viewModel.selectedFilter = .watering }
                            FilterChip(title: "Fertilizing", isSelected: viewModel.selectedFilter == .fertilizing, color: .plantSuccess)
                                .onTapGesture { viewModel.selectedFilter = .fertilizing }
                            FilterChip(title: "Repotting", isSelected: viewModel.selectedFilter == .repotting, color: .plantSuccess)
                                .onTapGesture { viewModel.selectedFilter = .repotting }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)

                List {
                    ForEach(viewModel.filteredHistory) { record in
                        HistoryCard(record: record)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteRecord(record)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .plantScreenBackdrop()
        }
    }
}
