//
//  PlantDetailView.swift
//  130PlantCare
//

import SwiftUI

struct PlantDetailView: View {
    @ObservedObject var viewModel: PlantCareViewModel
    let plantId: UUID
    @Environment(\.dismiss) private var dismiss

    @State private var showWaterSheet = false
    @State private var showFertilizeSheet = false
    @State private var showEditSheet = false
    @State private var waterNotes = ""
    @State private var fertilizeNotes = ""
    @State private var fertilizerType = ""

    private var plant: Plant? {
        viewModel.plants.first { $0.id == plantId }
    }

    var body: some View {
        Group {
            if let plant {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        header(plant)
                        careStatus(plant)
                        history(plant)
                        actionButtons(plant)
                    }
                    .padding(.bottom, 24)
                }
                .plantScreenBackdrop()
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $showWaterSheet) {
                    careNotesSheet(
                        title: "Log watering",
                        primaryTitle: "Water",
                        notes: $waterNotes,
                        onConfirm: {
                            guard let p = viewModel.plants.first(where: { $0.id == plantId }) else { return }
                            let n = waterNotes.trimmingCharacters(in: .whitespacesAndNewlines)
                            viewModel.waterPlant(p, notes: n.isEmpty ? nil : n)
                            waterNotes = ""
                            showWaterSheet = false
                        },
                        onCancel: {
                            waterNotes = ""
                            showWaterSheet = false
                        }
                    )
                }
                .sheet(isPresented: $showFertilizeSheet) {
                    fertilizeSheet
                }
                .sheet(isPresented: $showEditSheet) {
                    EditPlantView(viewModel: viewModel, plantId: plantId)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "leaf")
                        .font(.largeTitle)
                        .foregroundColor(.plantMuted)
                    Text("Plant not found")
                        .foregroundColor(.plantMuted)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .plantScreenBackdrop()
                .onAppear { dismiss() }
            }
        }
    }

    @ViewBuilder
    private func header(_ plant: Plant) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Circle()
                    .fill(PlantDesign.iconTileGradient)
                    .frame(width: 88, height: 88)
                    .shadow(color: Color.plantSuccess.opacity(0.22), radius: 16, x: 0, y: 8)
                Text(plant.type.emoji)
                    .font(.system(size: 44))
            }
            Text(plant.name)
                .font(.largeTitle)
                .bold()
                .foregroundStyle(PlantDesign.titleForeground)
            Text("\(plant.type.rawValue) · \(plant.location)")
                .font(.subheadline)
                .foregroundColor(.plantMuted)
            if plant.isFavorite {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.plantSuccess)
                    Text("Favorite")
                        .font(.caption)
                        .foregroundColor(.plantSuccess)
                }
            }
            if !plant.tagList.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(plant.tagList, id: \.self) { tag in
                            HStack(spacing: 4) {
                                Image(systemName: tag.icon)
                                    .font(.caption2)
                                Text(tag.rawValue)
                                    .font(.caption)
                            }
                            .foregroundColor(.plantSuccess)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .plantSoftLift(cornerRadius: 14)
                        }
                    }
                }
            }
        }
        .padding()
    }

    @ViewBuilder
    private func careStatus(_ plant: Plant) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatusCard(
                title: "Watering",
                status: plant.needsWatering ? "Needed" : "On track",
                nextDate: plant.nextWatering,
                color: plant.needsWatering ? .plantSuccess : .plantMuted,
                icon: "drop.fill"
            )
            StatusCard(
                title: "Fertilizing",
                status: plant.needsFertilizing ? "Needed" : "On track",
                nextDate: plant.nextFertilizing,
                color: plant.needsFertilizing ? .plantSuccess : .plantMuted,
                icon: "leaf.fill"
            )
            StatusCard(
                title: "Repotting",
                status: plant.needsRepotting ? "Needed" : "On track",
                nextDate: plant.nextRepotting,
                color: plant.needsRepotting ? .plantSuccess : .plantMuted,
                icon: "arrow.2.circlepath"
            )
            StatusCard(
                title: "Light",
                status: plant.lightRequirement.rawValue,
                nextDate: nil,
                color: .plantMuted,
                icon: plant.lightRequirement.icon
            )
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func history(_ plant: Plant) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("History")
                .font(.headline)
                .foregroundColor(.plantSuccess)
                .padding(.horizontal)

            let w = viewModel.waterings(for: plant.id)
            if !w.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Watering")
                        .font(.subheadline)
                        .foregroundColor(.plantSuccess)
                        .padding(.horizontal)
                    ForEach(w) { watering in
                        HistoryRow(
                            title: "Watering",
                            date: watering.date,
                            notes: watering.notes,
                            color: .plantSuccess
                        )
                    }
                }
            }

            let f = viewModel.fertilizings(for: plant.id)
            if !f.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Fertilizing")
                        .font(.subheadline)
                        .foregroundColor(.plantSuccess)
                        .padding(.horizontal)
                    ForEach(f) { item in
                        HistoryRow(
                            title: "Fertilizing",
                            date: item.date,
                            notes: combinedFertilizingNotes(item),
                            color: .plantSuccess
                        )
                    }
                }
            }

            let r = viewModel.repottings(for: plant.id)
            if !r.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Repotting")
                        .font(.subheadline)
                        .foregroundColor(.plantSuccess)
                        .padding(.horizontal)
                    ForEach(r) { item in
                        HistoryRow(
                            title: "Repotting",
                            date: item.date,
                            notes: combinedRepotNotes(item),
                            color: .plantSuccess
                        )
                    }
                }
            }
        }
        .padding(16)
        .plantElevatedCard(cornerRadius: PlantDesign.radiusCard)
        .padding(.horizontal)
    }

    @ViewBuilder
    private func actionButtons(_ plant: Plant) -> some View {
        HStack(spacing: 10) {
            Button {
                showWaterSheet = true
            } label: {
                Text("Water")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundColor(.white)
                    .plantPrimaryPill(cornerRadius: 12)
            }
            .buttonStyle(.plain)

            Button {
                fertilizeNotes = ""
                fertilizerType = ""
                showFertilizeSheet = true
            } label: {
                Text("Fertilize")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundColor(.white)
                    .plantSecondaryPill(cornerRadius: 12)
            }
            .buttonStyle(.plain)

            Button {
                showEditSheet = true
            } label: {
                Text("Edit")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundColor(.plantSuccess)
                    .plantSoftLift(cornerRadius: 12)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.plantSuccess.opacity(0.45), lineWidth: 1.5)
                    }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
    }

    private var fertilizeSheet: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Fertilizer type (optional)", text: $fertilizerType)
                        .tint(.plantSuccess)
                        .foregroundColor(.plantSuccess)
                }
                Section(header: Text("Notes").foregroundColor(.plantMuted)) {
                    TextEditor(text: $fertilizeNotes)
                        .frame(minHeight: 100)
                        .tint(.plantSuccess)
                        .foregroundColor(.plantSuccess)
                }
            }
            .scrollContentBackground(.hidden)
            .plantScreenBackdrop()
            .navigationTitle("Log fertilizing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showFertilizeSheet = false
                    }
                    .foregroundColor(.plantSuccess)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let p = viewModel.plants.first(where: { $0.id == plantId }) else { return }
                        let ft = fertilizerType.trimmingCharacters(in: .whitespacesAndNewlines)
                        let n = fertilizeNotes.trimmingCharacters(in: .whitespacesAndNewlines)
                        viewModel.fertilizePlant(
                            p,
                            fertilizerType: ft.isEmpty ? nil : ft,
                            notes: n.isEmpty ? nil : n
                        )
                        showFertilizeSheet = false
                    }
                    .bold()
                    .foregroundColor(.plantSuccess)
                }
            }
        }
    }

    private func careNotesSheet(
        title: String,
        primaryTitle: String,
        notes: Binding<String>,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) -> some View {
        NavigationStack {
            Form {
                Section(header: Text("Notes").foregroundColor(.plantMuted)) {
                    TextEditor(text: notes)
                        .frame(minHeight: 120)
                        .tint(.plantSuccess)
                        .foregroundColor(.plantSuccess)
                }
            }
            .scrollContentBackground(.hidden)
            .plantScreenBackdrop()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                        .foregroundColor(.plantSuccess)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(primaryTitle, action: onConfirm)
                        .bold()
                        .foregroundColor(.plantSuccess)
                }
            }
        }
    }

    private func combinedFertilizingNotes(_ item: FertilizingRecord) -> String? {
        let parts = [item.fertilizerType, item.notes]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    private func combinedRepotNotes(_ item: RepottingRecord) -> String? {
        let parts = [item.newPotSize, item.newSoil, item.notes]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }
}
