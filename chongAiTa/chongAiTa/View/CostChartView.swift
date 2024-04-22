//
//  CostChartView.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/22.
//

import Charts
import SwiftUI

struct CostChartView: View {
    @State private var costs: [(name: String, amount: Double)] = [
            ("Event A", 100.0),
            ("Event B", 200.0),
            ("Event C", 75.0)
        ]

    private func fetchData() {
        let allCosts = EventsManager.shared.getAllCosts()
        print("Fetched costs: \(allCosts)") // 打印從 EventsManager 獲取的數據

        // 轉換數據以適應圖表格式
        costs = allCosts.map { cost in
            // 假設我們想以事件的標題作為名稱
            let eventName = EventsManager.shared.loadEvents(for: Date()).first(where: { $0.id == cost.eventId })?.title ?? "Unknown Event"
            return (name: eventName, amount: cost.cost)
        }
    }

    var body: some View {
        Chart(costs, id: \.name) { data in
            BarMark(
                x: .value("Cost", data.amount),
                y: .value("Event", data.name)
            )
        }
        .onAppear {
            fetchData()
        }
    }
}


#Preview {
    CostChartView()
}
