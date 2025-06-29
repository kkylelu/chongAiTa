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
//        label.textColor = .darkGray
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
        
        layer.borderColor = UIColor.systemGray4.cgColor
        layer.borderWidth = 0.3
        
        circleBackgroundView.layer.cornerRadius = min(circleBackgroundView.frame.width, circleBackgroundView.frame.height) / 2
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
            #if DEBUG
            assertionFailure("init(coder:) has not been implemented")
            #endif
            return nil
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
                eventView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
                eventView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
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
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = color(for: event.category)
        label.layer.cornerRadius = 3
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func color(for category: ActivityCategory) -> UIColor {
        switch category {
        case .food:
            return UIColor.B3
        case .medication:
            return UIColor.B5
        case .shower:
            return UIColor.B7
        case .toy:
            return UIColor.B1
        case .walk:
            return UIColor.B6
        case .others:
            return UIColor.systemGray2
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
            circleBackgroundView.isHidden = false
            circleBackgroundView.backgroundColor = UIColor.B1
            dateLabel.textColor = .white
        } else {
            circleBackgroundView.isHidden = true
            if #available(iOS 13.0, *) {
                dateLabel.textColor = UIColor { (traitCollection) -> UIColor in
                    switch traitCollection.userInterfaceStyle {
                    case .dark:
                        return .white
                    default:
                        return .black
                    }
                }
            } else {
                dateLabel.textColor = .black
            }
        }
    }

}
