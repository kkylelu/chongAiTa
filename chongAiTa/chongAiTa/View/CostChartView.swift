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
                return (name: "Unknown", amount: cost.cost)
            }
        }
    }
    
    var body: some View {
        Chart {
            ForEach(costs, id: \.name) { data in
                SectorMark(
                    angle: .value("Cost", data.amount / totalCost),
                    innerRadius: .ratio(0.618),
                    angularInset: 1.5
                )
                .cornerRadius(5.0)
                .foregroundStyle(by: .value("Activity", data.name))
                .opacity(data.name == "Unknown" ? 0.3 : 1)
            }
        }
        .chartLegend(alignment: .center, spacing: 18)
        .scaledToFit()
        .onAppear {
            fetchData()
        }
    }
}

#Preview {
    CostChartView()
}
