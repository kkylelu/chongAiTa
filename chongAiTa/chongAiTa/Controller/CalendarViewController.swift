//
//  CalendarViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/19.
//

import UIKit

class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let weekHeaderView = UIView()
    let weekDays = ["一", "二", "三", "四", "五", "六", "日"]
    var collectionView: UICollectionView!
    var viewModel = CalendarViewModel()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureCollectionView()
        setupNavigationBar()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        collectionView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        collectionView.addGestureRecognizer(swipeRight)
        
        viewModel.updateView = { [weak self] in
            self?.collectionView.reloadData()
            self?.updateTitleButton()
        }
        
        viewModel.loadEventsForCurrentMonth()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadEventsForCurrentMonth()
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
        titleButton.setTitle(viewModel.titleForCurrentMonth(), for: .normal)
        titleButton.addTarget(self, action: #selector(presentDatePicker), for: .touchUpInside)
        titleButton.titleLabel?.adjustsFontSizeToFitWidth = true
        titleButton.titleLabel?.minimumScaleFactor = 0.5
        titleButton.contentHorizontalAlignment = .center
        
        navigationItem.leftBarButtonItem = previousMonthButton
        navigationItem.rightBarButtonItem = nextMonthButton
        navigationItem.titleView = titleButton
        
        if let titleView = navigationItem.titleView {
            titleView.sizeToFit()
        }
        
        titleButton.translatesAutoresizingMaskIntoConstraints = false
        navigationItem.titleView = titleButton
        NSLayoutConstraint.activate([
            titleButton.centerXAnchor.constraint(equalTo: navigationItem.titleView?.centerXAnchor ?? view.centerXAnchor),
            titleButton.centerYAnchor.constraint(equalTo: navigationItem.titleView?.centerYAnchor ?? view.centerYAnchor)
        ])
    }
    
    @objc func presentDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "zh_Hant_TW")
        datePicker.preferredDatePickerStyle = .wheels

        datePicker.minimumDate = Calendar.current.date(from: DateComponents(year: 2020))
        datePicker.maximumDate = Calendar.current.date(from: DateComponents(year: 2030))

        let popupView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300))

        if #available(iOS 13.0, *) {
            popupView.backgroundColor = UIColor { (traitCollection) -> UIColor in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return .black
                default:
                    return .white
                }
            }
        } else {
            view.backgroundColor = .white
        }
        
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
            viewModel.currentMonthDate = datePicker.date
            collectionView.reloadData()
            updateTitleButton()
        }
        dismissCustomPopup()
    }
    
    func updateTitleButton() {
        if let titleButton = navigationItem.titleView as? UIButton {
            titleButton.setTitle(viewModel.titleForCurrentMonth(), for: .normal)
        }
    }
    
    // MARK: - Action
    
    @objc func goToPreviousMonth() {
        viewModel.goToPreviousMonth()
    }
    
    @objc func goToNextMonth() {
        viewModel.goToNextMonth()
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            goToNextMonth()
        } else if gesture.direction == .right {
            goToPreviousMonth()
        }
    }
    
    // MARK: - CollectionView Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCell
        
        let firstDayIndex = viewModel.firstWeekdayOfMonth
        let dateOffset = indexPath.item - firstDayIndex
        let calendar = Calendar.current
        
        if dateOffset >= 0 && dateOffset < viewModel.daysInMonth {
            let dateForCell = calendar.date(byAdding: .day, value: dateOffset, to: viewModel.firstOfMonth())!
            let startOfDay = calendar.startOfDay(for: dateForCell)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            let events = EventsManager.shared.loadEvents(from: startOfDay, to: endOfDay)
            cell.configureCell(with: dateForCell, events: events.map {
                Event(title: $0.title, category: $0.activity.category)
            })
            
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let firstDayIndex = viewModel.firstWeekdayOfMonth
        let dateOffset = indexPath.item - firstDayIndex
        if dateOffset >= 0 && dateOffset < viewModel.daysInMonth {
            let selectedDate = Calendar.current.date(byAdding: .day, value: dateOffset, to: viewModel.firstOfMonth())!
            let calendarDateVC = CalendarDateViewController()
            calendarDateVC.selectedDate = selectedDate
            navigationController?.pushViewController(calendarDateVC, animated: true)
        }
    }
}

