//
//  OnboardingView.swift
//  130PlantCare
//

import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var page = 0

    private let pages: [(icon: String, title: String, message: String)] = [
        (
            "leaf.circle.fill",
            "Your plants in one place",
            "Add each plant with watering rhythm, light needs, and room — then keep notes as you go."
        ),
        (
            "calendar.badge.clock",
            "See what is due",
            "Today’s tasks, a seven-day care plan, and filters so you can focus on what matters."
        ),
        (
            "lock.shield.fill",
            "Yours only, on this device",
            "No account required. Optional daily reminders. Data stays local."
        )
    ]

    var body: some View {
        ZStack {
            PlantDesign.screenGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer(minLength: 0)
                    Button("Skip") {
                        onFinish()
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.plantMuted)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                TabView(selection: $page) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageContent(
                            icon: pages[index].icon,
                            title: pages[index].title,
                            message: pages[index].message
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .tint(.plantSuccess)

                Button {
                    if page < pages.count - 1 {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            page += 1
                        }
                    } else {
                        onFinish()
                    }
                } label: {
                    Text(page < pages.count - 1 ? "Next" : "Get started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .plantPrimaryPill(cornerRadius: 14)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 36)
            }
        }
    }
}

private struct OnboardingPageContent: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 20)

            ZStack {
                Circle()
                    .fill(PlantDesign.iconTileGradient)
                    .frame(width: 120, height: 120)
                    .shadow(color: Color.plantSuccess.opacity(0.28), radius: 20, x: 0, y: 12)
                Image(systemName: icon)
                    .font(.system(size: 52, weight: .medium))
                    .foregroundColor(.plantSuccess)
            }

            VStack(spacing: 14) {
                Text(title)
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(PlantDesign.titleForeground)

                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.plantMuted)
                    .padding(.horizontal, 28)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 40)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    OnboardingView(onFinish: {})
}
