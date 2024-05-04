//
//  CalendarViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/19.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

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
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calendarEventsArray.removeAll()
        loadEventsForCurrentMonth()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureFlowLayout()
        collectionView.reloadData()
    }
    
    // MARK: - Setup UI
    
    func setupUI() {
        applyDynamicBackgroundColor(lightModeColor: .white, darkModeColor: .black)
        
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DateCell.self, forCellWithReuseIdentifier: "DateCell")
        
        weekHeaderView.translatesAutoresizingMaskIntoConstraints = false
        weekHeaderView.backgroundColor = UIColor.B2
        
        view.addSubview(weekHeaderView)
        view.addSubview(collectionView)
        
        if #available(iOS 13.0, *) {
            collectionView.backgroundColor = UIColor { (traitCollection) -> UIColor in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return .black
                default:
                    return .white
                }
            }
        } else {
            collectionView.backgroundColor = .white
        }
        
        NSLayoutConstraint.activate([
            weekHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            weekHeaderView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            weekHeaderView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            weekHeaderView.heightAnchor.constraint(equalToConstant: 30),
        
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
            
            if day == "六" {
                dayLabel.textColor = UIColor.B5
            } else if day == "日" {
                dayLabel.textColor = UIColor.B7
            } else {
                dayLabel.textColor = UIColor.darkGray
            }
            
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
        datePicker.locale = Locale(identifier: "zh_Hant_TW")
        datePicker.preferredDatePickerStyle = .wheels

        datePicker.minimumDate = Calendar.current.date(from: DateComponents(year: 2020))
        datePicker.maximumDate = Calendar.current.date(from: DateComponents(year: 2030))

        let popupView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300))
        popupView.backgroundColor = .white
        popupView.layer.cornerRadius = 12
        popupView.clipsToBounds = true

        popupView.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            datePicker.centerYAnchor.constraint(equalTo: popupView.centerYAnchor),
            datePicker.widthAnchor.constraint(equalTo: popupView.widthAnchor),
            datePicker.heightAnchor.constraint(equalToConstant: 216)
        ])

        let selectButton = UIButton(type: .system)
        selectButton.setTitle("選擇", for: .normal)
        selectButton.tintColor = UIColor.B1
        selectButton.frame = CGRect(x: popupView.frame.width / 2, y: popupView.frame.height - 50, width: popupView.frame.width / 2, height: 50)
        selectButton.addTarget(self, action: #selector(selectButtonTapped(_:)), for: .touchUpInside)
        popupView.addSubview(selectButton)

        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.tintColor = UIColor.black
        cancelButton.frame = CGRect(x: 0, y: popupView.frame.height - 50, width: popupView.frame.width / 2, height: 50)
        cancelButton.addTarget(self, action: #selector(dismissCustomPopup), for: .touchUpInside)
        popupView.addSubview(cancelButton)

        // 顯示自定義視圖
        self.view.addSubview(popupView)
        popupView.center = self.view.center
    }

    @objc func dismissCustomPopup() {
        if let popupView = self.view.subviews.last {
            UIView.animate(withDuration: 0.3, animations: {
                popupView.alpha = 0
            }, completion: { _ in
                popupView.removeFromSuperview()
            })
        }
    }

    
    @objc func selectButtonTapped(_ sender: UIButton) {
        if let datePicker = self.view.subviews.last?.subviews.compactMap({ $0 as? UIDatePicker }).first {
            currentMonthDate = datePicker.date
            collectionView.reloadData()
            updateTitleButton()
        }
        dismissCustomPopup()
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
        
        if let currentUser = Auth.auth().currentUser {
            let userId = currentUser.uid
            
            FirestoreService.shared.fetchEvents(userId: userId, from: startOfMonth, to: endOfMonth) { [weak self] result in
                switch result {
                case .success(let events):
                    DispatchQueue.main.async {
                        events.forEach { event in
                            if !EventsManager.shared.hasEvent(event) { // 檢查活動是否已存在
                                EventsManager.shared.saveEvents([event])  // 保存不存在的活動
                            }
                        }
                        self?.collectionView.reloadData()
                    }
                case .failure(let error):
                    print("從 Firestore 獲取活動時出錯：\(error)")
                }
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
            cell.configureCell(with: dateForCell, events: events.map {
                Event(title: $0.title, category: $0.activity.category)
            })
            
            // 檢查日期是否是星期六或星期日
            let weekday = calendar.component(.weekday, from: dateForCell)
            if weekday == 7 {
                cell.dateLabel.textColor = UIColor.B5
            } else if weekday == 1 {
                cell.dateLabel.textColor = UIColor.B7
            } 
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
