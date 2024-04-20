//
//  DateEventListViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/20.
//

import UIKit

class DateEventListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    let today = Date()
    var events = [CalendarEvents]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupFakeData()
        tableView.reloadData()
    }
    
    // MARK: - Setup UI
    
    func setupUI(){
        view.backgroundColor = .yellow
        
    }
    
    // MARK: - Setup Fake Data
        
        func setupFakeData() {
            let calendar = Calendar.current
            events = [
                CalendarEvents(title: "餵食", date: calendar.date(byAdding: .day, value: 0, to: today)!),
                CalendarEvents(title: "運動", date: calendar.date(byAdding: .day, value: 1, to: today)!),
                CalendarEvents(title: "看醫生", date: calendar.date(byAdding: .day, value: 2, to: today)!)
            ]
        }
    
    
    func setupTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CardTableViewCell.self, forCellReuseIdentifier: "CardTableViewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    // MARK: - TableView Delegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardTableViewCell", for: indexPath) as? CardTableViewCell else {
            return UITableViewCell()
        }
        
        let event = events[indexPath.row]
        cell.configure(with: event)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let event = events[indexPath.row]
            let eventDetailVC = EventDetailViewController()
            // 傳遞事件數據到詳情頁面
            eventDetailVC.event = event
            navigationController?.pushViewController(eventDetailVC, animated: true)
        }
}
