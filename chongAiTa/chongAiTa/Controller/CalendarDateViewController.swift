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
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupFloatingButton()
        setupTableView()
        tableView.register(UINib(nibName: "JournalHomeTableViewCell", bundle: nil), forCellReuseIdentifier: "JournalHomeCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            print("viewWillAppear called")
            loadEvents()
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
    
    func loadEvents() {
        dataSource = EventsManager.shared.loadEvents(for: selectedDate)
        tableView.reloadData()
    }
    
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
            cell.configure(with: event)
            cell.selectionStyle = .none
            return cell
        }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 165.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = dataSource[indexPath.row]
        let eventDetailVC = EventDetailViewController()
        eventDetailVC.configure(event: event)
        navigationController?.pushViewController(eventDetailVC, animated: true)
    }

    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            let eventToDelete = self.dataSource[indexPath.row]
            self.dataSource.removeAll { $0.id == eventToDelete.id }
            EventsManager.shared.deleteEvent(eventToDelete)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }

        deleteAction.backgroundColor = UIColor.B4

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true

        return configuration
    }
}
