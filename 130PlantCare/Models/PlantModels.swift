//
//  PlantModels.swift
//  130PlantCare
//

import Foundation

enum PlantTag: String, CaseIterable, Codable, Hashable {
    case petSafe = "Pet safe"
    case toxicToPets = "Toxic to pets"
    case airPurifying = "Air purifying"
    case easyCare = "Easy care"

    var icon: String {
        switch self {
        case .petSafe: return "pawprint.fill"
        case .toxicToPets: return "exclamationmark.triangle.fill"
        case .airPurifying: return "wind"
        case .easyCare: return "sparkles"
        }
    }
}

enum PlantType: String, CaseIterable, Codable, Hashable {
    case succulent = "Succulent"
    case cactus = "Cactus"
    case fern = "Fern"
    case flowering = "Flowering"
    case foliage = "Foliage"
    case palm = "Palm"
    case orchid = "Orchid"
    case other = "Other"

    var icon: String {
        switch self {
        case .succulent: return "leaf.fill"
        case .cactus: return "cactus"
        case .fern: return "leaf"
        case .flowering: return "flower"
        case .foliage: return "tree.fill"
        case .palm: return "tree"
        case .orchid: return "flower"
        case .other: return "leaf"
        }
    }

    var emoji: String {
        switch self {
        case .succulent: return "🌵"
        case .cactus: return "🌵"
        case .fern: return "🌿"
        case .flowering: return "🌸"
        case .foliage: return "🌱"
        case .palm: return "🌴"
        case .orchid: return "🌺"
        case .other: return "🪴"
        }
    }
}

enum WaterFrequency: String, CaseIterable, Codable, Hashable {
    case daily = "Daily"
    case every2Days = "Every 2 days"
    case every3Days = "Every 3 days"
    case weekly = "Weekly"
    case every2Weeks = "Every 2 weeks"
    case monthly = "Monthly"
    case rarely = "Rarely"

    var days: Int {
        switch self {
        case .daily: return 1
        case .every2Days: return 2
        case .every3Days: return 3
        case .weekly: return 7
        case .every2Weeks: return 14
        case .monthly: return 30
        case .rarely: return 60
        }
    }
}

enum LightRequirement: String, CaseIterable, Codable, Hashable {
    case low = "Low light"
    case medium = "Medium light"
    case bright = "Bright indirect light"
    case direct = "Direct sunlight"

    var icon: String {
        switch self {
        case .low: return "moon.fill"
        case .medium: return "cloud.sun.fill"
        case .bright: return "sun.max.fill"
        case .direct: return "sun.horizon.fill"
        }
    }
}

struct Plant: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var type: PlantType
    var location: String
    var waterFrequency: WaterFrequency
    var lastWatered: Date?
    var fertilizerFrequency: WaterFrequency?
    var lastFertilized: Date?
    var repotFrequency: Int?
    var lastRepotted: Date?
    var lightRequirement: LightRequirement
    var notes: String?
    var imageName: String?
    var isFavorite: Bool
    /// Omitted in older saved data; treat as empty.
    var tags: [PlantTag]? = nil
    let createdAt: Date

    var tagList: [PlantTag] {
        tags ?? []
    }

    var nextWatering: Date? {
        guard let last = lastWatered else { return nil }
        return Calendar.current.date(byAdding: .day, value: waterFrequency.days, to: last)
    }

    var nextFertilizing: Date? {
        guard let freq = fertilizerFrequency, let last = lastFertilized else { return nil }
        return Calendar.current.date(byAdding: .day, value: freq.days, to: last)
    }

    var nextRepotting: Date? {
        guard let freq = repotFrequency, let last = lastRepotted else { return nil }
        return Calendar.current.date(byAdding: .month, value: freq, to: last)
    }

    var needsWatering: Bool {
        guard let next = nextWatering else { return false }
        return next <= Date()
    }

    var needsFertilizing: Bool {
        guard let next = nextFertilizing else { return false }
        return next <= Date()
    }

    var needsRepotting: Bool {
        guard let next = nextRepotting else { return false }
        return next <= Date()
    }
}

struct WateringRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let plantId: UUID
    let plantName: String
    let date: Date
    var notes: String?
}

struct FertilizingRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let plantId: UUID
    let plantName: String
    let date: Date
    var fertilizerType: String?
    var notes: String?
}

struct RepottingRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let plantId: UUID
    let plantName: String
    let date: Date
    var newPotSize: String?
    var newSoil: String?
    var notes: String?
}

struct PlantPhoto: Identifiable, Codable, Hashable {
    let id: UUID
    let plantId: UUID
    let imageName: String
    let date: Date
    var notes: String?
}

struct ReminderSetting: Codable, Equatable {
    var isEnabled: Bool
    var time: Date
}

struct SeasonalChecklistItem: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var isCompleted: Bool
}
