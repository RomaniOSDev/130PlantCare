//
//  EditPlantView.swift
//  130PlantCare
//

import SwiftUI

struct EditPlantView: View {
    @ObservedObject var viewModel: PlantCareViewModel
    let plantId: UUID
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var type: PlantType = .foliage
    @State private var location = ""
    @State private var waterFrequency: WaterFrequency = .weekly
    @State private var lastWatered = Date()
    @State private var hasFertilizer = false
    @State private var fertilizerFrequency: WaterFrequency = .monthly
    @State private var lastFertilized = Date()
    @State private var hasRepotting = false
    @State private var repotFrequency = 12
    @State private var lastRepotted = Date()
    @State private var lightRequirement: LightRequirement = .bright
    @State private var notes = ""
    @State private var isFavorite = false
    @State private var selectedTags: Set<PlantTag> = []

    var body: some View {
        NavigationStack {
            Group {
                if let plant = viewModel.plants.first(where: { $0.id == plantId }) {
                    Form {
                        Section {
                            TextField("Name", text: $name)
                                .foregroundColor(.plantSuccess)
                                .tint(.plantSuccess)
                            Picker("Type", selection: $type) {
                                ForEach(PlantType.allCases, id: \.self) { t in
                                    Text("\(t.emoji) \(t.rawValue)").tag(t)
                                }
                            }
                            .tint(.plantSuccess)
                            TextField("Location", text: $location)
                                .foregroundColor(.plantSuccess)
                                .tint(.plantSuccess)
                        }

                        Section(header: Text("Care").foregroundColor(.plantMuted)) {
                            Picker("Watering frequency", selection: $waterFrequency) {
                                ForEach(WaterFrequency.allCases, id: \.self) { freq in
                                    Text(freq.rawValue).tag(freq)
                                }
                            }
                            .tint(.plantSuccess)
                            DatePicker("Last watered", selection: $lastWatered, displayedComponents: .date)
                                .tint(.plantSuccess)
                            Toggle("Fertilizing schedule", isOn: $hasFertilizer)
                                .tint(.plantSuccess)
                            if hasFertilizer {
                                Picker("Fertilizing frequency", selection: $fertilizerFrequency) {
                                    ForEach(WaterFrequency.allCases, id: \.self) { freq in
                                        Text(freq.rawValue).tag(freq)
                                    }
                                }
                                .tint(.plantSuccess)
                                DatePicker("Last fertilized", selection: $lastFertilized, displayedComponents: .date)
                                    .tint(.plantSuccess)
                            }
                            Toggle("Repotting schedule", isOn: $hasRepotting)
                                .tint(.plantSuccess)
                            if hasRepotting {
                                HStack {
                                    Text("Every (months)")
                                    Spacer()
                                    Picker("", selection: $repotFrequency) {
                                        ForEach(6...24, id: \.self) { months in
                                            Text("\(months) mo").tag(months)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(.plantSuccess)
                                }
                                DatePicker("Last repotted", selection: $lastRepotted, displayedComponents: .date)
                                    .tint(.plantSuccess)
                            }
                        }

                        Section(header: Text("Light").foregroundColor(.plantMuted)) {
                            Picker("Light needs", selection: $lightRequirement) {
                                ForEach(LightRequirement.allCases, id: \.self) { light in
                                    Label(light.rawValue, systemImage: light.icon).tag(light)
                                }
                            }
                            .tint(.plantSuccess)
                        }

                        Section(header: Text("Notes").foregroundColor(.plantMuted)) {
                            TextEditor(text: $notes)
                                .frame(height: 80)
                                .foregroundColor(.plantSuccess)
                                .tint(.plantSuccess)
                        }

                        Section(header: Text("Tags").foregroundColor(.plantMuted)) {
                            ForEach(PlantTag.allCases, id: \.self) { tag in
                                Toggle(isOn: Binding(
                                    get: { selectedTags.contains(tag) },
                                    set: { on in
                                        if on {
                                            selectedTags.insert(tag)
                                        } else {
                                            selectedTags.remove(tag)
                                        }
                                    }
                                )) {
                                    Label(tag.rawValue, systemImage: tag.icon)
                                }
                                .tint(.plantSuccess)
                            }
                        }

                        Section {
                            Toggle("Favorite", isOn: $isFavorite)
                                .tint(.plantSuccess)
                        }
                    }
                    .foregroundColor(.plantSuccess)
                    .scrollContentBackground(.hidden)
                    .plantScreenBackdrop()
                    .navigationTitle("Edit")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { dismiss() }
                                .foregroundColor(.plantSuccess)
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                save(from: plant)
                            }
                            .bold()
                            .foregroundColor(.plantSuccess)
                        }
                    }
                    .onAppear {
                        hydrate(from: plant)
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
    }

    private func hydrate(from plant: Plant) {
        name = plant.name
        type = plant.type
        location = plant.location == "—" ? "" : plant.location
        waterFrequency = plant.waterFrequency
        lastWatered = plant.lastWatered ?? Date()
        hasFertilizer = plant.fertilizerFrequency != nil
        fertilizerFrequency = plant.fertilizerFrequency ?? .monthly
        lastFertilized = plant.lastFertilized ?? Date()
        hasRepotting = plant.repotFrequency != nil
        repotFrequency = plant.repotFrequency ?? 12
        lastRepotted = plant.lastRepotted ?? Date()
        lightRequirement = plant.lightRequirement
        notes = plant.notes ?? ""
        isFavorite = plant.isFavorite
        selectedTags = Set(plant.tagList)
    }

    private func save(from plant: Plant) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        let trimmedLocation = location.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        var updated = plant
        updated.name = trimmedName
        updated.type = type
        updated.location = trimmedLocation.isEmpty ? "—" : trimmedLocation
        updated.waterFrequency = waterFrequency
        updated.lastWatered = lastWatered
        updated.fertilizerFrequency = hasFertilizer ? fertilizerFrequency : nil
        updated.lastFertilized = hasFertilizer ? lastFertilized : nil
        updated.repotFrequency = hasRepotting ? repotFrequency : nil
        updated.lastRepotted = hasRepotting ? lastRepotted : nil
        updated.lightRequirement = lightRequirement
        updated.notes = trimmedNotes.isEmpty ? nil : trimmedNotes
        updated.isFavorite = isFavorite
        updated.tags = selectedTags.isEmpty ? nil : Array(selectedTags).sorted { $0.rawValue < $1.rawValue }
        viewModel.updatePlant(updated)
        dismiss()
    }
}
