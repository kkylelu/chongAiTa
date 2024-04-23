//
//  CostChartView.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/22.
//

import Charts
import SwiftUI

struct CostChartView: View {
    @State private var costs: [(name: String, amount: Double)] = []
    @State private var totalCost: Double = 0

    private func fetchData() {
        let allCosts = EventsManager.shared.getAllCosts()
        totalCost = allCosts.map { $0.cost }.reduce(0, +)
        costs = allCosts.map { cost in
            if let event = EventsManager.shared.loadEvent(with: cost.eventId) {
                let activityName = event.activity.category.displayName
                return (name: activityName, amount: cost.cost)
            } else {
                return (name: "未分類", amount: cost.cost)
            }
        }
    }

    var body: some View {
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
                        Text("\(cost.amount / totalCost, specifier: "%.2f%%")").frame(alignment: .trailing)
                        Spacer().frame(width: 20)
                        Text("\(cost.amount, specifier: "$%.2f")").frame(alignment: .trailing)
                    }
                }
            }
        }
        .listStyle(.plain)
        .onAppear {
            fetchData()
        }
    }
}

#Preview {
    CostChartView()
}
