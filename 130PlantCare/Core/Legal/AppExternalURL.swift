//
//  AppExternalURL.swift
//  130PlantCare
//

import Foundation

/// Legal and policy URLs. Replace with production endpoints before release.
enum AppExternalURL: String, CaseIterable, Identifiable {
    case privacyPolicy = "https://www.termsfeed.com/live/78f45651-5828-4736-9382-ee1fc5975479"
    case termsOfUse = "https://www.termsfeed.com/live/476b539c-e7b5-4b07-b608-9a0c7416e641"

    var id: String { rawValue }

    var displayTitle: String {
        switch self {
        case .privacyPolicy: return "Privacy Policy"
        case .termsOfUse: return "Terms of Use"
        }
    }
}
