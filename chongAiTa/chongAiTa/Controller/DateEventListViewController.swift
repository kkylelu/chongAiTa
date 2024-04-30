//
//  DateEventListViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/20.
//

import UIKit

class DateEventListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var selectedDate: Date
    var collectionView: UICollectionView!
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
        setupCollectionView()
        setupPresetActivities()
    }

    func setupUI() {
        view.backgroundColor = .systemGray6
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width / 2 - 10, height: 100)  // 設定每個項目的尺寸
        layout.minimumInteritemSpacing = 10  // 項目間的最小間距
        layout.minimumLineSpacing = 10       // 行間的最小間距

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ActivityCollectionViewCell.self, forCellWithReuseIdentifier: "ActivityCollectionViewCell")
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    func setupPresetActivities() {
        defaultActivities = [
            DefaultActivity(category: .food, date: selectedDate),
            DefaultActivity(category: .shower, date: selectedDate),
            DefaultActivity(category: .medication, date: selectedDate)
        ]
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return defaultActivities.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActivityCollectionViewCell", for: indexPath) as? ActivityCollectionViewCell else {
            fatalError("Unable to dequeue ActivityCollectionViewCell")
        }

        let activity = defaultActivities[indexPath.item]
        cell.configure(with: activity.category.displayName, icon: getIconForCategory(activity.category), date: activity.date)
        return cell
    }

    // 獲取分類圖標
    func getIconForCategory(_ category: ActivityCategory) -> UIImage {
        switch category {
        case .food:
            return UIImage(named: "foodIcon")!
        case .medication:
            return UIImage(named: "medicationIcon")!
        case .shower:
            return UIImage(named: "dogShowerIcon")!
        }
    }
}

