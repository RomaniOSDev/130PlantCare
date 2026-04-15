//
//  HomeSeasonalSection.swift
//  130PlantCare
//

import SwiftUI

struct HomeSeasonalSection: View {
    @ObservedObject var viewModel: PlantCareViewModel
    @State private var newItemTitle = ""
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "leaf.circle.fill")
                        .foregroundColor(.plantMuted)
                    Text("Seasonal checklist")
                        .font(.headline)
                        .foregroundColor(.plantSuccess)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.plantMuted)
                        .rotationEffect(.degrees(isExpanded ? 0 : -90))
                }
            }
            .buttonStyle(.plain)

            Text("Stored on this device only.")
                .font(.caption)
                .foregroundColor(.plantMuted)

            if isExpanded {
                HStack(spacing: 8) {
                    TextField("New item", text: $newItemTitle)
                        .padding(10)
                        .plantSoftLift(cornerRadius: 10)
                        .tint(.plantSuccess)
                        .foregroundColor(.plantSuccess)
                    Button {
                        viewModel.addSeasonalChecklistItem(title: newItemTitle)
                        newItemTitle = ""
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Color.plantSuccess)
                    }
                    .disabled(newItemTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                if viewModel.seasonalChecklist.isEmpty {
                    Text("Add misting, grow lights, pest checks…")
                        .font(.caption)
                        .foregroundColor(.plantMuted)
                        .padding(.vertical, 4)
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(viewModel.seasonalChecklist) { item in
                            HStack(alignment: .center, spacing: 12) {
                                Button {
                                    viewModel.toggleSeasonalChecklistItem(item)
                                } label: {
                                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .font(.title3)
                                        .foregroundColor(item.isCompleted ? .plantMuted : .plantSuccess)
                                }
                                .buttonStyle(.plain)
                                Text(item.title)
                                    .font(.subheadline)
                                    .foregroundColor(item.isCompleted ? .plantMuted : .plantSuccess)
                                    .strikethrough(item.isCompleted)
                                Spacer(minLength: 0)
                            }
                            .padding(.vertical, 10)
                            .contentShape(Rectangle())
                            .contextMenu {
                                Button(role: .destructive) {
                                    viewModel.deleteSeasonalChecklistItem(item)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            if item.id != viewModel.seasonalChecklist.last?.id {
                                Divider()
                                    .background(Color.plantMuted.opacity(0.25))
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding(16)
        .homeCardBackground()
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 8, leading: HomeLayout.horizontalPadding, bottom: 8, trailing: HomeLayout.horizontalPadding))
    }
}
