//
//  SettingsView.swift
//  130PlantCare
//

import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        rateApp()
                    } label: {
                        Label("Rate us", systemImage: "star.fill")
                            .foregroundColor(.plantSuccess)
                    }

                    Button {
                        openPolicy(AppExternalURL.privacyPolicy)
                    } label: {
                        Label(AppExternalURL.privacyPolicy.displayTitle, systemImage: "hand.raised.fill")
                            .foregroundColor(.plantSuccess)
                    }

                    Button {
                        openPolicy(AppExternalURL.termsOfUse)
                    } label: {
                        Label(AppExternalURL.termsOfUse.displayTitle, systemImage: "doc.text.fill")
                            .foregroundColor(.plantSuccess)
                    }
                } header: {
                    Text("Support & legal")
                        .foregroundColor(.plantMuted)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .plantScreenBackdrop()
    }

    private func openPolicy(_ link: AppExternalURL) {
        if let url = URL(string: link.rawValue) {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

#Preview {
    SettingsView()
}
