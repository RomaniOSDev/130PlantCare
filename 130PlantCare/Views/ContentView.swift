//
//  ContentView.swift
//  130PlantCare
//

import SwiftUI
import UIKit

struct ContentView: View {
    @AppStorage("plantcare_onboarding_completed") private var onboardingCompleted = false
    @StateObject private var viewModel = PlantCareViewModel()
    @State private var selectedTab = 0

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor(red: 0.97, green: 0.99, blue: 0.98, alpha: 0.98)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        Group {
            if onboardingCompleted {
                mainTabView
            } else {
                OnboardingView {
                    onboardingCompleted = true
                }
            }
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            HistoryView(viewModel: viewModel)
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .tag(1)

            StatsView(viewModel: viewModel)
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(.plantSuccess)
        .onAppear {
            viewModel.loadFromUserDefaults()
        }
    }
}

#Preview {
    ContentView()
}
