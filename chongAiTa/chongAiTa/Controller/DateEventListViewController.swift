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

    // MARK: - Setup UI
    func setupUI() {
        view.backgroundColor = .systemGray6
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let spacing = CGFloat(10)
        layout.itemSize = CGSize(width: (view.frame.width / 2) - (spacing * 2), height: 50)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)  

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ActivityCollectionViewCell.self, forCellWithReuseIdentifier: "ActivityCollectionViewCell")
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ])
    }


    
    func setupPresetActivities() {
        defaultActivities = [
            DefaultActivity(category: .food, date: selectedDate),
            DefaultActivity(category: .shower, date: selectedDate),
            DefaultActivity(category: .medication, date: selectedDate)
        ]
    }
    
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
    
    // MARK: - CollectionView Delegate

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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activity = defaultActivities[indexPath.item]
        let icon = getIconForCategory(activity.category)
        let displayName = activity.category.displayName
        let selectedTime = activity.date

        let event = CalendarEvents(
            title: displayName,
            date: selectedTime,
            activity: activity,
            image: icon
        )

        let eventDetailVC = EventDetailViewController()
        eventDetailVC.configure(event: event)
        navigationController?.pushViewController(eventDetailVC, animated: true)
    }

   
}

