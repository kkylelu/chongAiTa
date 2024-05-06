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
    var emptyPlaceholderLabel: UILabel!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupFloatingButton()
        setupTableView()
        setNavigationTitle(.calendarDate)
        tableView.register(UINib(nibName: "JournalHomeTableViewCell", bundle: nil), forCellReuseIdentifier: "JournalHomeCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewEvent(_:)), name: .didCreateEvent, object: nil)
        setupEmptyPlaceholderLabel()
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear called")
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        loadEvents(from: startOfDay, to: endOfDay)
    }
    
    // MARK: - Setup UI
    
    func setupUI(){
        applyDynamicBackgroundColor(lightModeColor: .white, darkModeColor: .black)
    }
    
    func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.backgroundColor = .white
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
    
    func setupEmptyPlaceholderLabel() {
        emptyPlaceholderLabel = UILabel()
        emptyPlaceholderLabel.text = "點擊下方「加號圖示➕」新增活動"
        emptyPlaceholderLabel.textColor = UIColor.gray
        emptyPlaceholderLabel.textAlignment = .center
        emptyPlaceholderLabel.font = UIFont.systemFont(ofSize: 20)
        emptyPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyPlaceholderLabel)
        
        NSLayoutConstraint.activate([
            emptyPlaceholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyPlaceholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyPlaceholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyPlaceholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        emptyPlaceholderLabel.isHidden = true
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
    
    // MARK: - UpdateUI
    
    func updateUI() {
        emptyPlaceholderLabel.isHidden = !dataSource.isEmpty
        tableView.isHidden = dataSource.isEmpty
        tableView.reloadData()
    }
    
    // MARK: - Action
    
    func loadEvents(from startDate: Date, to endDate: Date) {
        dataSource = EventsManager.shared.loadEvents(from: startDate, to: endDate)
        tableView.reloadData()
        updateUI()
    }
    
    @objc func floatingButtonTapped() {
        
        // 提供觸覺回饋
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator.prepare()
        impactFeedbackGenerator.impactOccurred()
        
        let dateEventListVC = DateEventListViewController(date: selectedDate)

        if let presentationController = dateEventListVC.presentationController as? UISheetPresentationController {
            presentationController.detents = [
                .custom { [unowned self] _ in
                    let targetHeight = self.view.frame.size.height * 0.25
                    return .init(targetHeight)
                }
            ]
            presentationController.prefersGrabberVisible = true
        }
        
        self.present(dateEventListVC, animated: true, completion: nil)
    }

    @objc func handleNewEvent(_ notification: Notification) {
        if let event = notification.object as? CalendarEvents {
            dataSource.append(event)
            tableView.reloadData()
            updateUI()
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh_Hant_TW")
        dateFormatter.dateFormat = "yyyy 年 M 月 d 日 EEEE"
        let formattedDate = dateFormatter.string(from: event.date)
        
        cell.configure(with: event, formattedDate: formattedDate)
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
            
            self.updateUI()
        }
        
        deleteAction.backgroundColor = UIColor.B4
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
}
