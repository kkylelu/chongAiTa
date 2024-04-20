//
//  CalendarDateViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/20.
//

import UIKit

class CalendarDateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    var floatingButton: UIButton!
    var selectedDate: Date = Date()
    var dataSource = [CalendarEvents]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupFloatingButton()
        setupTableView()
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewEvent(_:)), name: .didCreateEvent, object: nil)
        
        tableView.register(UINib(nibName: "JournalHomeTableViewCell", bundle: nil), forCellReuseIdentifier: "JournalHomeCell")
        
    }
    
    // MARK: - Setup UI
    
    func setupUI(){
        view.backgroundColor = .white
        
    }
    
    func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UINib(nibName: "JournalHomeTableViewCell", bundle: nil), forCellReuseIdentifier: "JournalHomeCell")
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: floatingButton.topAnchor, constant: -10)
        ])
    }
    
    
    func setupFloatingButton(){
        floatingButton = UIButton(type: .custom)
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        floatingButton.backgroundColor = UIColor.B1
        
        let image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium))
        
        floatingButton.setImage(image, for: .normal)
        floatingButton.tintColor = .white
        floatingButton.layer.cornerRadius = 28
        floatingButton.layer.shadowOpacity = 0.3
        floatingButton.layer.shadowRadius = 4
        floatingButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        floatingButton.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
        
        view.addSubview(floatingButton)
        
        NSLayoutConstraint.activate([
            floatingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
            floatingButton.widthAnchor.constraint(equalToConstant: 56),
            floatingButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
    }
    
    // MARK: - Action
    
    @objc func floatingButtonTapped() {
        let dateEventListVC = DateEventListViewController(date: selectedDate)
        navigationController?.pushViewController(dateEventListVC, animated: true)
    }
    
    @objc func handleNewEvent(_ notification: Notification) {
        if let event = notification.object as? CalendarEvents {
            dataSource.append(event)
            tableView.reloadData()
        }
    }
    
    
    // MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "JournalHomeCell", for: indexPath) as? JournalHomeTableViewCell else {
            fatalError("無法取得 JournalHomeTableViewCell 的實例。")
        }
        let event = dataSource[indexPath.row]
        cell.timeLabel.text = DateFormatter.localizedString(from: event.date, dateStyle: .short, timeStyle: .short)
        cell.journalTitleLabel.text = event.title.isEmpty ? event.activity.category.displayName : event.title
        cell.journalContentLabel.text = event.content
        cell.JournalImageView.image = event.image
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 165.0
    }
}
