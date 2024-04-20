//
//  EventDetailViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/20.
//

import UIKit

class EventDetailViewController: UIViewController {

    var event: CalendarEvents?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()

    }
    
    // MARK: - Setup UI
    
    func setupUI() {
        view.backgroundColor = .blue
    }

}
