//
//  DateCell.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/19.
//

import UIKit

struct Event {
    var title: String
    var category: ActivityCategory
}

class DateCell: UICollectionViewCell {
    
    let circleBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.B1
        view.isHidden = true
        return view
    }()
    
    var isCurrentDate: Bool = false {
        didSet {
            updateDateLabelAppearance()
        }
    }
    
    var dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.backgroundColor = .clear
        return label
    }()
    
    var eventViews: [UIView] = []
    var moreEventsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.text = "…"
        label.isHidden = true
        return label
    }()
    
    // MARK: - Life Cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0.5
        
        circleBackgroundView.layer.cornerRadius = min(circleBackgroundView.frame.width, circleBackgroundView.frame.height) / 2
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 重用前確認清除所有 eventView
        eventViews.forEach { $0.removeFromSuperview() }
        eventViews = []
        moreEventsLabel.isHidden = true
    }
    
    // MARK: Setup UI
    func setupViews() {
        contentView.addSubview(circleBackgroundView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(moreEventsLabel)
        
        circleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        moreEventsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            circleBackgroundView.topAnchor.constraint(equalTo: dateLabel.topAnchor),
            circleBackgroundView.bottomAnchor.constraint(equalTo: dateLabel.bottomAnchor),
            circleBackgroundView.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            circleBackgroundView.trailingAnchor.constraint(equalTo: dateLabel.trailingAnchor),
            circleBackgroundView.widthAnchor.constraint(equalTo: circleBackgroundView.heightAnchor),
            
            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            
            moreEventsLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            moreEventsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
        
        updateDateLabelAppearance()
    }
    
    func configureCell(with date: Date?, events: [Event]) {
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "d"  // 只顯示日期數字
            dateLabel.text = formatter.string(from: date)
            isCurrentDate = Calendar.current.isDateInToday(date)
        } else {
            dateLabel.text = nil
            isCurrentDate = false
        }

        // 移除舊的 event views
        eventViews.forEach { $0.removeFromSuperview() }
        eventViews = []
        
        // 增加新的 event views
        let totalEventsToShow = min(events.count, 3)
        var lastBottomAnchor = dateLabel.bottomAnchor
        for event in events.prefix(totalEventsToShow) {
            let eventView = createEventView(for: event)
            contentView.addSubview(eventView)
            NSLayoutConstraint.activate([
                eventView.topAnchor.constraint(equalTo: lastBottomAnchor, constant: 2),
                eventView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                eventView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                eventView.heightAnchor.constraint(equalToConstant: 14)
            ])
            lastBottomAnchor = eventView.bottomAnchor
            eventViews.append(eventView)
        }

        // 是否顯示更多活動的標籤
        moreEventsLabel.isHidden = events.count <= 3
        if !moreEventsLabel.isHidden {
            setupEventLabel(moreEventsLabel, below: lastBottomAnchor)
        }
    }

    
    func createEventView(for event: Event) -> UILabel {
        let label = UILabel()
        label.text = event.title
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = color(for: event.category)
        label.layer.cornerRadius = 6
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    // 根據活動類別返回相對應的顏色
    func color(for category: ActivityCategory) -> UIColor {
        switch category {
        case .food:
            return UIColor.orange
        case .medication:
            return UIColor.yellow
        case .shower:
            return UIColor.brown
        }
    }
    
    func setupEventLabel(_ label: UILabel, below anchor: NSLayoutYAxisAnchor) {
        contentView.addSubview(label)
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: anchor, constant: 2),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.heightAnchor.constraint(equalToConstant: 14)
        ])
        eventViews.append(label)
    }
    
    func updateDateLabelAppearance() {
        if isCurrentDate {
            dateLabel.textColor = .white
            circleBackgroundView.isHidden = false
            circleBackgroundView.backgroundColor = UIColor.B1
        } else {
            dateLabel.textColor = .black
            circleBackgroundView.isHidden = true
        }
    }

    
}
