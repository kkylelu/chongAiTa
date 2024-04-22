//
//  CostChartViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/22.
//

import UIKit
import SwiftUI

class CostChartViewController: UIViewController {
    private var hostingController: UIHostingController<CostChartView>?

    override func viewDidLoad() {
        super.viewDidLoad()

        let chartView = CostChartView()
        hostingController = UIHostingController(rootView: chartView)
        addChild(hostingController!)
        view.addSubview(hostingController!.view)
        hostingController!.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController!.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController!.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController!.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController!.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

