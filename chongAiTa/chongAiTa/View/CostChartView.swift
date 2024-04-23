//
//  CostChartView.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/22.
//

import Charts
import SwiftUI

enum TimeRange: String, CaseIterable {
    case lastWeek = "上週"
    case currentMonth = "本月"
}

struct TimeRangePicker: View {
    @Binding var selectedTimeRange: TimeRange
    
    var body: some View {
        Picker("時間範圍", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { timeRange in
                Text(timeRange.rawValue)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

struct CostChartView: View {
    @State private var costs: [(name: String, amount: Double)] = []
    @State private var totalCost: Double = 0
    @State private var selectedTimeRange: TimeRange = .lastWeek

    private func fetchData() {
        let allCosts: [(eventId: UUID, cost: Double)]
        switch selectedTimeRange {
        case .lastWeek:
            allCosts = EventsManager.shared.getCostsForLastWeek()
        case .currentMonth:
            allCosts = EventsManager.shared.getCostsForCurrentMonth()
        }

        var categoryTotalCosts: [String: Double] = [:]

        for cost in allCosts {
            if let event = EventsManager.shared.loadEvent(with: cost.eventId) {
                let categoryName = event.activity.category.displayName
                categoryTotalCosts[categoryName, default: 0] += cost.cost
            } else {
                categoryTotalCosts["未分類", default: 0] += cost.cost
            }
        }

        totalCost = categoryTotalCosts.values.reduce(0, +)
        costs = categoryTotalCosts.map { (name, amount) in (name, amount) }
    }

    var body: some View {
        VStack {
            if costs.isEmpty {
                Text("先新增活動支出，就能查看圖表")
                    .padding()
            } else {
                TimeRangePicker(selectedTimeRange: $selectedTimeRange)
                    .onChange(of: selectedTimeRange) { _ in
                        fetchData()
                    }

                List {
                    Chart(costs, id: \.name) { element in
                        SectorMark(
                            angle: .value("Cost", element.amount),
                            innerRadius: .ratio(0.618),
                            angularInset: 1.5
                        )
                        .cornerRadius(5.0)
                        .foregroundStyle(by: .value("Activity", element.name))
                    }
                    .chartLegend(alignment: .center)
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                    .frame(height: 300)

                    Section(header: Text("花費項目")) {
                        ForEach(costs, id: \.name) { cost in
                            HStack {
                                Text(cost.name)
                                Spacer()
                                Text("\(Int((cost.amount / totalCost) * 100))%")
                                    .frame(alignment: .trailing)
                                Spacer().frame(width: 20)
                                Text("$\(cost.amount, specifier: "%.2f")")
                                    .frame(alignment: .trailing)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .onAppear {
            fetchData()
        }
    }
}

#Preview {
    CostChartView()
}

