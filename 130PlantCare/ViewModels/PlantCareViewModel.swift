//
//  PlantCareViewModel.swift
//  130PlantCare
//

import Combine
import Foundation
import UserNotifications

@MainActor
final class PlantCareViewModel: ObservableObject {
    @Published var plants: [Plant] = []
    @Published var waterings: [WateringRecord] = []
    @Published var fertilizings: [FertilizingRecord] = []
    @Published var repottings: [RepottingRecord] = []
    @Published var selectedFilter: HistoryFilter?
    @Published var reminderSetting: ReminderSetting = ReminderSetting(isEnabled: false, time: Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date())

    // MARK: - Dashboard list: search, filters, sort
    @Published var dashboardSearchText = ""
    @Published var filterRoom: String?
    @Published var filterPlantType: PlantType?
    @Published var filterFavoritesOnly = false
    @Published var filterNeedsWaterOnly = false
    @Published var plantSortOrder: PlantSortOrder = .nameAZ

    @Published var seasonalChecklist: [SeasonalChecklistItem] = []

    enum PlantSortOrder: String, CaseIterable, Identifiable {
        case nameAZ = "Name (A–Z)"
        case nextWatering = "Next watering"
        case mostOverdue = "Most overdue"

        var id: String { rawValue }
    }

    enum HistoryFilter: String, CaseIterable {
        case watering, fertilizing, repotting
    }

    var uniqueRoomLocations: [String] {
        let raw = plants.map(\.location)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0 != "—" }
        return Array(Set(raw)).sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    var hasActivePlantListFilters: Bool {
        let q = dashboardSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return !q.isEmpty
            || filterRoom != nil
            || filterPlantType != nil
            || filterFavoritesOnly
            || filterNeedsWaterOnly
    }

    func clearPlantListFilters() {
        dashboardSearchText = ""
        filterRoom = nil
        filterPlantType = nil
        filterFavoritesOnly = false
        filterNeedsWaterOnly = false
    }

    private func nextWateringSortKey(_ plant: Plant) -> Date {
        plant.nextWatering ?? .distantFuture
    }

    var filteredSortedPlants: [Plant] {
        var result = plants
        let q = dashboardSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !q.isEmpty {
            result = result.filter { plant in
                if plant.name.localizedCaseInsensitiveContains(q) { return true }
                if plant.location.localizedCaseInsensitiveContains(q) { return true }
                return plant.tagList.contains { $0.rawValue.localizedCaseInsensitiveContains(q) }
            }
        }
        if let room = filterRoom {
            result = result.filter { $0.location == room }
        }
        if let t = filterPlantType {
            result = result.filter { $0.type == t }
        }
        if filterFavoritesOnly {
            result = result.filter(\.isFavorite)
        }
        if filterNeedsWaterOnly {
            result = result.filter(\.needsWatering)
        }

        switch plantSortOrder {
        case .nameAZ:
            return result.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        case .nextWatering:
            return result.sorted {
                let a = nextWateringSortKey($0)
                let b = nextWateringSortKey($1)
                if a == b {
                    return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                }
                return a < b
            }
        case .mostOverdue:
            return result.sorted { a, b in
                let aOver = a.needsWatering
                let bOver = b.needsWatering
                if aOver != bOver { return aOver && !bOver }
                if aOver && bOver {
                    let da = a.nextWatering ?? .distantPast
                    let db = b.nextWatering ?? .distantPast
                    if da != db { return da < db }
                    return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
                }
                let da = nextWateringSortKey(a)
                let db = nextWateringSortKey(b)
                if da != db { return da < db }
                return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
            }
        }
    }

    // MARK: - Care plan (7 days)

    struct CarePlanEntry: Identifiable {
        let id: String
        let plantId: UUID
        let plantName: String
        let title: String
        let icon: String
    }

    struct CarePlanDayBlock: Identifiable {
        let id: String
        let date: Date
        let heading: String
        let items: [CarePlanEntry]
    }

    var carePlanNextSevenDays: [CarePlanDayBlock] {
        let cal = Calendar.current
        let todayStart = cal.startOfDay(for: Date())
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, MMM d"

        return (0..<7).compactMap { offset -> CarePlanDayBlock? in
            guard let day = cal.date(byAdding: .day, value: offset, to: todayStart) else { return nil }
            let dayStart = cal.startOfDay(for: day)
            var seen = Set<String>()
            var entries: [CarePlanEntry] = []

            func appendEntry(plant: Plant, suffix: String, title: String, icon: String) {
                let key = "\(plant.id.uuidString)-\(suffix)"
                guard !seen.contains(key) else { return }
                seen.insert(key)
                entries.append(CarePlanEntry(
                    id: key,
                    plantId: plant.id,
                    plantName: plant.name,
                    title: title,
                    icon: icon
                ))
            }

            for plant in plants {
                if offset == 0 {
                    if plant.needsWatering {
                        appendEntry(plant: plant, suffix: "water", title: "Watering", icon: "drop.fill")
                    } else if let nw = plant.nextWatering, cal.isDate(nw, inSameDayAs: dayStart) {
                        appendEntry(plant: plant, suffix: "water", title: "Watering", icon: "drop.fill")
                    }
                    if plant.needsFertilizing {
                        appendEntry(plant: plant, suffix: "fert", title: "Fertilizing", icon: "leaf.fill")
                    } else if let nf = plant.nextFertilizing, cal.isDate(nf, inSameDayAs: dayStart) {
                        appendEntry(plant: plant, suffix: "fert", title: "Fertilizing", icon: "leaf.fill")
                    }
                    if plant.needsRepotting {
                        appendEntry(plant: plant, suffix: "repot", title: "Repotting", icon: "arrow.2.circlepath")
                    } else if let nr = plant.nextRepotting, cal.isDate(nr, inSameDayAs: dayStart) {
                        appendEntry(plant: plant, suffix: "repot", title: "Repotting", icon: "arrow.2.circlepath")
                    }
                } else {
                    if let nw = plant.nextWatering, cal.isDate(nw, inSameDayAs: dayStart) {
                        appendEntry(plant: plant, suffix: "water", title: "Watering", icon: "drop.fill")
                    }
                    if let nf = plant.nextFertilizing, cal.isDate(nf, inSameDayAs: dayStart) {
                        appendEntry(plant: plant, suffix: "fert", title: "Fertilizing", icon: "leaf.fill")
                    }
                    if let nr = plant.nextRepotting, cal.isDate(nr, inSameDayAs: dayStart) {
                        appendEntry(plant: plant, suffix: "repot", title: "Repotting", icon: "arrow.2.circlepath")
                    }
                }
            }

            entries.sort { $0.plantName.localizedCaseInsensitiveCompare($1.plantName) == .orderedAscending }

            let heading: String
            switch offset {
            case 0: heading = "Today"
            case 1: heading = "Tomorrow"
            default: heading = formatter.string(from: day)
            }

            return CarePlanDayBlock(
                id: "\(dayStart.timeIntervalSince1970)",
                date: day,
                heading: heading,
                items: entries
            )
        }
    }

    var plantsNeedingWater: Int {
        plants.filter(\.needsWatering).count
    }

    var healthyPlants: Int {
        plants.filter { !$0.needsWatering && !$0.needsFertilizing && !$0.needsRepotting }.count
    }

    var upcomingTasks: Int {
        plants.reduce(0) { count, plant in
            var c = count
            if plant.needsWatering { c += 1 }
            if plant.needsFertilizing { c += 1 }
            if plant.needsRepotting { c += 1 }
            return c
        }
    }

    enum TodayTaskKind: String {
        case watering, fertilizing, repotting
    }

    struct TodayTask: Identifiable {
        let plantId: UUID
        let plantName: String
        let title: String
        let icon: String
        let isUrgent: Bool
        let kind: TodayTaskKind

        var id: String { "\(plantId.uuidString)-\(kind.rawValue)" }
    }

    var todayTasks: [TodayTask] {
        var tasks: [TodayTask] = []
        for plant in plants {
            if plant.needsWatering {
                tasks.append(TodayTask(
                    plantId: plant.id,
                    plantName: plant.name,
                    title: "Watering",
                    icon: "drop.fill",
                    isUrgent: true,
                    kind: .watering
                ))
            }
            if plant.needsFertilizing {
                tasks.append(TodayTask(
                    plantId: plant.id,
                    plantName: plant.name,
                    title: "Fertilizing",
                    icon: "leaf.fill",
                    isUrgent: false,
                    kind: .fertilizing
                ))
            }
            if plant.needsRepotting {
                tasks.append(TodayTask(
                    plantId: plant.id,
                    plantName: plant.name,
                    title: "Repotting",
                    icon: "arrow.2.circlepath",
                    isUrgent: false,
                    kind: .repotting
                ))
            }
        }
        return tasks
    }

    var totalWaterings: Int { waterings.count }
    var totalFertilizings: Int { fertilizings.count }
    var totalRepottings: Int { repottings.count }

    struct TypeDistribution: Identifiable {
        let plantType: PlantType
        let count: Int

        var id: String { plantType.rawValue }
        var name: String { plantType.rawValue }
        var emoji: String { plantType.emoji }
    }

    var typeDistribution: [TypeDistribution] {
        let grouped = Dictionary(grouping: plants, by: \.type)
        return grouped.map { type, list in
            TypeDistribution(plantType: type, count: list.count)
        }
        .sorted { $0.count > $1.count }
    }

    struct WateringFrequencyStat: Identifiable {
        let frequency: WaterFrequency
        let count: Int

        var id: String { frequency.rawValue }
    }

    var wateringFrequency: [WateringFrequencyStat] {
        let grouped = Dictionary(grouping: plants, by: \.waterFrequency)
        return grouped.map { freq, list in
            WateringFrequencyStat(frequency: freq, count: list.count)
        }
        .sorted { $0.frequency.days < $1.frequency.days }
    }

    struct HistoryRecord: Identifiable {
        let id: UUID
        let plantId: UUID
        let plantName: String
        let title: String
        let icon: String
        let date: Date
        let notes: String?
        let kind: HistoryFilter
    }

    var filteredHistory: [HistoryRecord] {
        var records: [HistoryRecord] = []
        if selectedFilter == nil || selectedFilter == .watering {
            for w in waterings {
                records.append(HistoryRecord(
                    id: w.id,
                    plantId: w.plantId,
                    plantName: w.plantName,
                    title: "Watering",
                    icon: "drop.fill",
                    date: w.date,
                    notes: w.notes,
                    kind: .watering
                ))
            }
        }
        if selectedFilter == nil || selectedFilter == .fertilizing {
            for f in fertilizings {
                let combinedNotes: String? = {
                    let parts = [f.fertilizerType, f.notes].compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
                    return parts.isEmpty ? nil : parts.joined(separator: " · ")
                }()
                records.append(HistoryRecord(
                    id: f.id,
                    plantId: f.plantId,
                    plantName: f.plantName,
                    title: "Fertilizing",
                    icon: "leaf.fill",
                    date: f.date,
                    notes: combinedNotes,
                    kind: .fertilizing
                ))
            }
        }
        if selectedFilter == nil || selectedFilter == .repotting {
            for r in repottings {
                records.append(HistoryRecord(
                    id: r.id,
                    plantId: r.plantId,
                    plantName: r.plantName,
                    title: "Repotting",
                    icon: "arrow.2.circlepath",
                    date: r.date,
                    notes: r.notes,
                    kind: .repotting
                ))
            }
        }
        return records.sorted { $0.date > $1.date }
    }

    func waterings(for plantId: UUID) -> [WateringRecord] {
        waterings.filter { $0.plantId == plantId }.sorted { $0.date > $1.date }
    }

    func fertilizings(for plantId: UUID) -> [FertilizingRecord] {
        fertilizings.filter { $0.plantId == plantId }.sorted { $0.date > $1.date }
    }

    func repottings(for plantId: UUID) -> [RepottingRecord] {
        repottings.filter { $0.plantId == plantId }.sorted { $0.date > $1.date }
    }

    func addPlant(_ plant: Plant) {
        plants.append(plant)
        saveToUserDefaults()
        rescheduleCareNotificationsIfNeeded()
    }

    func updatePlant(_ plant: Plant) {
        if let index = plants.firstIndex(where: { $0.id == plant.id }) {
            plants[index] = plant
            saveToUserDefaults()
            rescheduleCareNotificationsIfNeeded()
        }
    }

    func deletePlant(_ plant: Plant) {
        plants.removeAll { $0.id == plant.id }
        waterings.removeAll { $0.plantId == plant.id }
        fertilizings.removeAll { $0.plantId == plant.id }
        repottings.removeAll { $0.plantId == plant.id }
        saveToUserDefaults()
        rescheduleCareNotificationsIfNeeded()
    }

    func waterPlant(_ plant: Plant, notes: String? = nil) {
        let record = WateringRecord(id: UUID(), plantId: plant.id, plantName: plant.name, date: Date(), notes: notes)
        waterings.append(record)
        if let index = plants.firstIndex(where: { $0.id == plant.id }) {
            plants[index].lastWatered = Date()
        }
        saveToUserDefaults()
        rescheduleCareNotificationsIfNeeded()
    }

    func fertilizePlant(_ plant: Plant, fertilizerType: String?, notes: String? = nil) {
        let record = FertilizingRecord(
            id: UUID(),
            plantId: plant.id,
            plantName: plant.name,
            date: Date(),
            fertilizerType: fertilizerType,
            notes: notes
        )
        fertilizings.append(record)
        if let index = plants.firstIndex(where: { $0.id == plant.id }) {
            plants[index].lastFertilized = Date()
        }
        saveToUserDefaults()
        rescheduleCareNotificationsIfNeeded()
    }

    func repotPlant(_ plant: Plant, newPotSize: String?, newSoil: String?, notes: String? = nil) {
        let record = RepottingRecord(
            id: UUID(),
            plantId: plant.id,
            plantName: plant.name,
            date: Date(),
            newPotSize: newPotSize,
            newSoil: newSoil,
            notes: notes
        )
        repottings.append(record)
        if let index = plants.firstIndex(where: { $0.id == plant.id }) {
            plants[index].lastRepotted = Date()
        }
        saveToUserDefaults()
        rescheduleCareNotificationsIfNeeded()
    }

    func deleteRecord(_ record: HistoryRecord) {
        switch record.kind {
        case .watering:
            waterings.removeAll { $0.id == record.id }
        case .fertilizing:
            fertilizings.removeAll { $0.id == record.id }
        case .repotting:
            repottings.removeAll { $0.id == record.id }
        }
        saveToUserDefaults()
    }

    // MARK: - Seasonal checklist (local)

    func addSeasonalChecklistItem(title: String) {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        seasonalChecklist.append(SeasonalChecklistItem(id: UUID(), title: t, isCompleted: false))
        saveSeasonalChecklist()
    }

    func toggleSeasonalChecklistItem(_ item: SeasonalChecklistItem) {
        guard let i = seasonalChecklist.firstIndex(where: { $0.id == item.id }) else { return }
        seasonalChecklist[i].isCompleted.toggle()
        saveSeasonalChecklist()
    }

    func deleteSeasonalChecklistItem(_ item: SeasonalChecklistItem) {
        seasonalChecklist.removeAll { $0.id == item.id }
        saveSeasonalChecklist()
    }

    func completeTask(_ task: TodayTask) {
        guard let plant = plants.first(where: { $0.id == task.plantId }) else { return }
        switch task.kind {
        case .watering:
            waterPlant(plant)
        case .fertilizing:
            fertilizePlant(plant, fertilizerType: nil, notes: nil)
        case .repotting:
            repotPlant(plant, newPotSize: nil, newSoil: nil, notes: nil)
        }
    }

    func updateReminderSetting(_ setting: ReminderSetting) {
        reminderSetting = setting
        saveReminderSetting()
        if setting.isEnabled {
            requestNotificationAuthorizationIfNeeded { [weak self] granted in
                guard let self else { return }
                Task { @MainActor in
                    if granted {
                        self.rescheduleCareNotificationsIfNeeded()
                    } else {
                        self.reminderSetting.isEnabled = false
                        self.saveReminderSetting()
                    }
                }
            }
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Self.dailySummaryId])
        }
    }

    private let plantsKey = "plantcare_plants"
    private let wateringsKey = "plantcare_waterings"
    private let fertilizingsKey = "plantcare_fertilizings"
    private let repottingsKey = "plantcare_repottings"
    private let reminderKey = "plantcare_reminder_setting"
    private let seasonalKey = "plantcare_seasonal_checklist"

    private static let dailySummaryId = "plantcare_daily_summary"

    private func saveSeasonalChecklist() {
        if let data = try? JSONEncoder().encode(seasonalChecklist) {
            UserDefaults.standard.set(data, forKey: seasonalKey)
        }
    }

    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(plants) {
            UserDefaults.standard.set(encoded, forKey: plantsKey)
        }
        if let encoded = try? JSONEncoder().encode(waterings) {
            UserDefaults.standard.set(encoded, forKey: wateringsKey)
        }
        if let encoded = try? JSONEncoder().encode(fertilizings) {
            UserDefaults.standard.set(encoded, forKey: fertilizingsKey)
        }
        if let encoded = try? JSONEncoder().encode(repottings) {
            UserDefaults.standard.set(encoded, forKey: repottingsKey)
        }
    }

    private func saveReminderSetting() {
        if let data = try? JSONEncoder().encode(reminderSetting) {
            UserDefaults.standard.set(data, forKey: reminderKey)
        }
    }

    func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: plantsKey),
           let decoded = try? JSONDecoder().decode([Plant].self, from: data) {
            plants = decoded
        }
        if let data = UserDefaults.standard.data(forKey: wateringsKey),
           let decoded = try? JSONDecoder().decode([WateringRecord].self, from: data) {
            waterings = decoded
        }
        if let data = UserDefaults.standard.data(forKey: fertilizingsKey),
           let decoded = try? JSONDecoder().decode([FertilizingRecord].self, from: data) {
            fertilizings = decoded
        }
        if let data = UserDefaults.standard.data(forKey: repottingsKey),
           let decoded = try? JSONDecoder().decode([RepottingRecord].self, from: data) {
            repottings = decoded
        }
        if let data = UserDefaults.standard.data(forKey: reminderKey),
           let decoded = try? JSONDecoder().decode(ReminderSetting.self, from: data) {
            reminderSetting = decoded
        }
        if let data = UserDefaults.standard.data(forKey: seasonalKey),
           let decoded = try? JSONDecoder().decode([SeasonalChecklistItem].self, from: data) {
            seasonalChecklist = decoded
        }
        if plants.isEmpty {
            loadDemoData()
        }
        rescheduleCareNotificationsIfNeeded()
    }

    private func loadDemoData() {
        let plant = Plant(
            id: UUID(),
            name: "Monstera",
            type: .foliage,
            location: "Living room",
            waterFrequency: .weekly,
            lastWatered: Date().addingTimeInterval(-86400 * 5),
            fertilizerFrequency: .monthly,
            lastFertilized: Date().addingTimeInterval(-86400 * 25),
            repotFrequency: 12,
            lastRepotted: Date().addingTimeInterval(-86400 * 400),
            lightRequirement: .bright,
            notes: "Enjoys misting",
            imageName: nil,
            isFavorite: true,
            tags: [.easyCare, .airPurifying],
            createdAt: Date()
        )
        plants = [plant]
        let watering = WateringRecord(
            id: UUID(),
            plantId: plant.id,
            plantName: plant.name,
            date: Date().addingTimeInterval(-86400 * 5),
            notes: nil
        )
        waterings = [watering]
        saveToUserDefaults()
    }

    private func requestNotificationAuthorizationIfNeeded(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                completion(true)
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    completion(granted)
                }
            default:
                completion(false)
            }
        }
    }

    private func rescheduleCareNotificationsIfNeeded() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Self.dailySummaryId])
        guard reminderSetting.isEnabled else { return }

        let count = upcomingTasks
        let content = UNMutableNotificationContent()
        content.title = "Care reminders"
        if count == 0 {
            content.body = "You have no pending care tasks today."
        } else {
            content.body = "You have \(count) care task\(count == 1 ? "" : "s") due."
        }
        content.sound = .default

        let cal = Calendar.current
        let comps = cal.dateComponents([.hour, .minute], from: reminderSetting.time)
        var triggerComponents = DateComponents()
        triggerComponents.hour = comps.hour
        triggerComponents.minute = comps.minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)
        let request = UNNotificationRequest(identifier: Self.dailySummaryId, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
