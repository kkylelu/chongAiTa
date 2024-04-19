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
    var currentMonthDate = Date()
    
    // 目前月份的天數
    var daysInMonth: Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentMonthDate)!
        return range.count
    }
    
    var firstWeekdayOfMonth: Int {
        let calendar = Calendar.current
        // 週日為一週的第一天，如果不是，可以適當調整
        var components = calendar.dateComponents([.year, .month], from: currentMonthDate)
        components.day = 1
        let firstDayOfMonthDate = calendar.date(from: components)!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonthDate)
        
        // 將星期天作為索引0，若將星期一作為索引0，可以再減1
        return firstWeekday - 2
    }
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureCollectionView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureFlowLayout()
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
    
    
    // MARK: - CollectionView Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 加上月初前的空格
        return 42 //daysInMonth + (firstWeekdayOfMonth - 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCell
        let date = Calendar.current.date(byAdding: .day, value: indexPath.item, to: Date()) // 生成日期假資料
            let events = [
                Event(title: "公園散步"),
                Event(title: "打針"),
                Event(title: "洗澡"),
                Event(title: "看獸醫")
            ]

            cell.configureCell(with: date, events: events)
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 點擊日期開新的 VC
    }
    
}
