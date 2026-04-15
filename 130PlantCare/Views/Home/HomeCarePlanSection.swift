//
//  HomeCarePlanSection.swift
//  130PlantCare
//

import SwiftUI

struct HomeCarePlanSection: View {
    @ObservedObject var viewModel: PlantCareViewModel
    @Binding var path: [UUID]
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.plantSuccess)
                    Text("Care plan")
                        .font(.headline)
                        .foregroundColor(.plantSuccess)
                    Spacer()
                    Text("7 days")
                        .font(.caption)
                        .foregroundColor(.plantMuted)
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.plantMuted)
                        .rotationEffect(.degrees(isExpanded ? 0 : -90))
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                Text("Tap a row to open the plant.")
                    .font(.caption)
                    .foregroundColor(.plantMuted)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.carePlanNextSevenDays) { day in
                        HomeCarePlanDayCard(day: day, path: $path)
                    }
                }
            }
        }
        .padding(16)
        .homeCardBackground()
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 8, leading: HomeLayout.horizontalPadding, bottom: 8, trailing: HomeLayout.horizontalPadding))
    }
}

private struct HomeCarePlanDayCard: View {
    let day: PlantCareViewModel.CarePlanDayBlock
    @Binding var path: [UUID]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(day.heading)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.plantSuccess)
            if day.items.isEmpty {
                Text("Nothing scheduled")
                    .font(.caption)
                    .foregroundColor(.plantMuted)
            } else {
                ForEach(day.items) { entry in
                    Button {
                        path.append(entry.plantId)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: entry.icon)
                                .foregroundColor(.plantSuccess)
                                .frame(width: 24, alignment: .center)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.plantName)
                                    .font(.subheadline)
                                    .foregroundColor(.plantSuccess)
                                Text(entry.title)
                                    .font(.caption)
                                    .foregroundColor(.plantMuted)
                            }
                            Spacer(minLength: 0)
                            Image(systemName: "chevron.right")
                                .font(.caption2.weight(.semibold))
                                .foregroundColor(.plantMuted.opacity(0.8))
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(PlantDesign.cardGradient)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(PlantDesign.cardBorderGradient(opacity: 0.1), lineWidth: 1)
                                }
                                .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 2)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: HomeLayout.cardCorner, style: .continuous)
                .fill(Color.plantSuccess.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: HomeLayout.cardCorner, style: .continuous)
                .stroke(Color.plantSuccess.opacity(0.08), lineWidth: 1)
        )
    }
}
