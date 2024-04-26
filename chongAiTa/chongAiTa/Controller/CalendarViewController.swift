//
//  CalendarViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/19.
//

import UIKit
import FirebaseFirestore

class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let weekHeaderView = UIView()
    let weekDays = ["一", "二", "三", "四", "五", "六", "日"]
    var collectionView: UICollectionView!
    var currentMonthDate = Date()
    var calendarEventsArray: [CalendarEvents] = []
    var eventsListener: ListenerRegistration?

        
    // 目前月份的天數
    var daysInMonth: Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentMonthDate)!
        return range.count
    }
    
    var firstWeekdayOfMonth: Int {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: currentMonthDate)
        components.day = 1
        let firstDayOfMonthDate = calendar.date(from: components)!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonthDate)
        
        // 設定工作日第一天為星期一
        return firstWeekday - 2
    }
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureCollectionView()
        setupNavigationBar()
        startListeningForEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadEventsForCurrentMonth()
        
        let startOfMonth = firstOfMonth()
        let endOfMonth = Calendar.current.date(byAdding: .month, value: 1, to: startOfMonth)!
        
        FirestoreService.shared.fetchEvents(from: startOfMonth, to: endOfMonth) { [weak self] result in
            switch result {
            case .success(let events):
                EventsManager.shared.saveEvents(events)
                self?.collectionView.reloadData()
            case .failure(let error):
                print("Error fetching events from Firestore: \(error)")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureFlowLayout()
        collectionView.reloadData()
    }
    
    // MARK: - Setup UI
    
    func setupUI() {
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DateCell.self, forCellWithReuseIdentifier: "DateCell")
        
        weekHeaderView.translatesAutoresizingMaskIntoConstraints = false
        weekHeaderView.backgroundColor = .systemGray6
        
        view.addSubview(weekHeaderView)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            weekHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            weekHeaderView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            weekHeaderView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            weekHeaderView.heightAnchor.constraint(equalToConstant: 20),
            
            collectionView.topAnchor.constraint(equalTo: weekHeaderView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
        
        // 新增星期標籤到 weekHeaderView 中
        var lastAnchor = weekHeaderView.leadingAnchor
        for day in weekDays {
            let dayLabel = UILabel()
            dayLabel.text = day
            dayLabel.textAlignment = .center
            weekHeaderView.addSubview(dayLabel)
            dayLabel.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                dayLabel.topAnchor.constraint(equalTo: weekHeaderView.topAnchor),
                dayLabel.bottomAnchor.constraint(equalTo: weekHeaderView.bottomAnchor),
                dayLabel.widthAnchor.constraint(equalTo: weekHeaderView.widthAnchor, multiplier: 1/CGFloat(weekDays.count)),
                dayLabel.leadingAnchor.constraint(equalTo: lastAnchor)
            ])
            lastAnchor = dayLabel.trailingAnchor
        }
    }
    
    func configureCollectionView() {
        configureFlowLayout()
    }
    
    func configureFlowLayout() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let itemWidth = collectionView.bounds.width / 7
        let itemHeight = collectionView.bounds.height / 6
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.invalidateLayout()
    }
    
    func setupNavigationBar() {
        let previousMonthButton = UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(goToPreviousMonth))
        let nextMonthButton = UIBarButtonItem(title: ">", style: .plain, target: self, action: #selector(goToNextMonth))
        
        let titleButton = UIButton(type: .system)
        titleButton.setTitle(titleForCurrentMonth(), for: .normal)
        titleButton.addTarget(self, action: #selector(presentDatePicker), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = previousMonthButton
        navigationItem.rightBarButtonItem = nextMonthButton
        // 將 UIButton 設置為 titleView
        navigationItem.titleView = titleButton
    }
    
    @objc func presentDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self, action: #selector(datePickerDidChange(_:)), for: .valueChanged)
        
        var dateComponents = DateComponents()
        dateComponents.year = Calendar.current.component(.year, from: Date())
        dateComponents.month = Calendar.current.component(.month, from: Date())
        let calendar = Calendar.current
        datePicker.minimumDate = calendar.date(from: DateComponents(year: 2020))
        datePicker.maximumDate = calendar.date(from: DateComponents(year: 2030))
        
        let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        alertController.view.addSubview(datePicker)
        
        let selectAction = UIAlertAction(title: "選擇", style: .default, handler: { _ in
            self.datePickerDidChange(datePicker)
        })
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(selectAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func datePickerDidChange(_ sender: UIDatePicker) {
        currentMonthDate = sender.date
        collectionView.reloadData()
        updateTitleButton()
    }
    
    func updateTitleButton() {
        if let titleButton = navigationItem.titleView as? UIButton {
            titleButton.setTitle(titleForCurrentMonth(), for: .normal)
        }
    }
    
    // MARK: - Action
    
    @objc func goToPreviousMonth() {
        guard let prevMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: currentMonthDate) else { return }
        currentMonthDate = prevMonthDate
        collectionView.reloadData()
        updateTitleButton()
    }
    
    @objc func goToNextMonth() {
        guard let nextMonthDate = Calendar.current.date(byAdding: .month, value: 1, to: currentMonthDate) else { return }
        currentMonthDate = nextMonthDate
        collectionView.reloadData()
        updateTitleButton()
    }
    
    func titleForCurrentMonth() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy 年 MM 月"
        return formatter.string(from: currentMonthDate)
    }
    
    func loadEventsForCurrentMonth() {
        let startOfMonth = firstOfMonth()
        let endOfMonth = Calendar.current.date(byAdding: .month, value: 1, to: startOfMonth)!

        FirestoreService.shared.fetchEvents(from: startOfMonth, to: endOfMonth) { [weak self] result in
            switch result {
            case .success(let events):
                EventsManager.shared.saveEvents(events)
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print("從 Firestore 獲取事件時出錯：\(error)")
            }
        }
    }
    
    func startListeningForEvents() {
        let startOfMonth = firstOfMonth()
        let endOfMonth = Calendar.current.date(byAdding: .month, value: 1, to: startOfMonth)!
        
        eventsListener = FirestoreService.shared.db.collection("events")
            .whereField("date", isGreaterThanOrEqualTo: startOfMonth)
            .whereField("date", isLessThanOrEqualTo: endOfMonth)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error listening for events changes: \(error)")
                } else if let snapshot = snapshot, !snapshot.metadata.hasPendingWrites {
                    let events = snapshot.documents.compactMap { document -> CalendarEvents? in
                        let data = document.data()
                        guard let id = data["id"] as? String,
                              let title = data["title"] as? String,
                              let date = (data["date"] as? Timestamp)?.dateValue(),
                              let activityData = data["activity"] as? [String: Any],
                              let categoryRawValue = activityData["category"] as? Int,
                              let category = ActivityCategory(rawValue: categoryRawValue),
                              let activityDate = (activityData["date"] as? Timestamp)?.dateValue() else {
                            return nil
                        }
                        
                        let content = data["content"] as? String
                        let cost = data["cost"] as? Double
                        let recurrenceRawValue = data["recurrence"] as? String
                        let recurrence = Recurrence(rawValue: recurrenceRawValue ?? "")
                        
                        let activity = DefaultActivity(category: category, date: activityDate)
                        
                        return CalendarEvents(
                            id: UUID(uuidString: id)!,
                            title: title,
                            date: date,
                            activity: activity,
                            content: content,
                            cost: cost,
                            recurrence: recurrence
                        )
                    }
                    // 檢查是否已存在，避免重複儲存
                    events.forEach { event in
                        if !EventsManager.shared.hasEvent(event) {
                            EventsManager.shared.saveEvents([event])
                        }
                    }
                    self?.collectionView.reloadData()
                }
            }
    }

    
    // MARK: - CollectionView Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCell
        
        let firstDayIndex = firstWeekdayOfMonth
        let dateOffset = indexPath.item - firstDayIndex
        let calendar = Calendar.current
        
        if dateOffset >= 0 && dateOffset < daysInMonth {
            let dateForCell = calendar.date(byAdding: .day, value: dateOffset, to: firstOfMonth())!
            let startOfDay = calendar.startOfDay(for: dateForCell)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            let events = EventsManager.shared.loadEvents(from: startOfDay, to: endOfDay)
            cell.configureCell(with: dateForCell, events: events.map { Event(title: $0.title) })
        } else {
            cell.configureCell(with: nil, events: [])
        }
        
        return cell
    }
    
    func firstOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: currentMonthDate)
        return calendar.date(from: components)!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let firstDayIndex = firstWeekdayOfMonth
        let dateOffset = indexPath.item - firstDayIndex
        if dateOffset >= 0 && dateOffset < daysInMonth {
            // 確保點擊的是有效日期
            let selectedDate = Calendar.current.date(byAdding: .day, value: dateOffset, to: firstOfMonth())!
            
            let calendarDateVC = CalendarDateViewController()
            calendarDateVC.selectedDate = selectedDate
            navigationController?.pushViewController(calendarDateVC, animated: true)
        }
    }

}
