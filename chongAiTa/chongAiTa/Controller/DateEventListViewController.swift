//
//  DateEventListViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/20.
//

import UIKit

class DateEventListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var selectedDate: Date
    var tableView: UITableView!
    var defaultActivities: [DefaultActivity] = []
    
    init(date: Date) {
        self.selectedDate = date
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupPresetActivities()
        tableView.reloadData()
    }
    
    // MARK: - Setup UI
    
    func setupUI() {
        view.backgroundColor = .yellow
    }
    
    func getIconForCategory(_ category: ActivityCategory) -> UIImage {
        switch category {
        case .food:
            return UIImage(named: "foodIcon")!
        case .medication:
            return UIImage(named: "medicationIcon")!
        case .exercise:
            return UIImage(named: "exerciseIcon")!
        }
    }
    
    func setupPresetActivities() {
        let calendar = Calendar.current
        defaultActivities = [
            DefaultActivity(category: .food, date: selectedDate),
            DefaultActivity(category: .exercise, date: selectedDate),
            DefaultActivity(category: .medication, date: selectedDate)
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
        return defaultActivities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardTableViewCell", for: indexPath) as? CardTableViewCell else {
            return UITableViewCell()
        }
        
        let defaultActivity = defaultActivities[indexPath.row]
        let icon = getIconForCategory(defaultActivity.category)
        cell.configure(with: defaultActivity.category.displayName, icon: icon, date: defaultActivity.date)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let defaultActivity = defaultActivities[indexPath.row]
        let eventDetailVC = EventDetailViewController()
        let icon = getIconForCategory(defaultActivity.category)
        let displayName = defaultActivity.category.displayName
        let selectedTime = defaultActivity.date
        eventDetailVC.configure(image: icon, title: displayName, date: selectedTime, activity: defaultActivity)
        navigationController?.pushViewController(eventDetailVC, animated: true)
    }
}
