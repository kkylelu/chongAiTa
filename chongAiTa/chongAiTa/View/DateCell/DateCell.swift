//
//  DateCell.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/19.
//

import UIKit

struct Event {
    var title: String
}

class DateCell: UICollectionViewCell {
    
    var dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .black
        label.backgroundColor = .white
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
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup UI
    private func setupViews() {
        contentView.addSubview(dateLabel)
        contentView.addSubview(moreEventsLabel)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        moreEventsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            
            moreEventsLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            moreEventsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }
    
    func configureCell(with date: Date?, events: [Event]) {
        dateLabel.text = date != nil ? DateFormatter.localizedString(from: date!, dateStyle: .medium, timeStyle: .none) : ""
        // 移除舊的事件視圖
        eventViews.forEach { $0.removeFromSuperview() }
        eventViews = []

        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "d"
            dateLabel.text = formatter.string(from: date)
        } else {
            dateLabel.text = nil
        }
        
        let dateLabelHeight: CGFloat = 20
        let spacing: CGFloat = 2
        let totalEventsToShow = min(events.count, 4)
        let availableHeight = contentView.bounds.height - dateLabelHeight - CGFloat(totalEventsToShow - 1) * spacing
        let eventHeight: CGFloat = availableHeight / CGFloat(totalEventsToShow)
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            dateLabel.heightAnchor.constraint(equalToConstant: dateLabelHeight)
        ])
        
        var lastBottomAnchor = dateLabel.bottomAnchor
        for (index, event) in events.enumerated() {
            // 只顯示前三個事件
            if index < 3 {
                let eventLabel = UILabel()
                eventLabel.text = event.title
                eventLabel.font = UIFont.systemFont(ofSize: 10)
                eventLabel.textColor = .darkGray
                eventLabel.textAlignment = .center
                eventLabel.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(eventLabel)

                NSLayoutConstraint.activate([
                    eventLabel.topAnchor.constraint(equalTo: lastBottomAnchor, constant: spacing),
                    eventLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                    eventLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                    eventLabel.heightAnchor.constraint(equalToConstant: eventHeight)
                ])
                lastBottomAnchor = eventLabel.bottomAnchor
                eventViews.append(eventLabel)
                // 第四個位置顯示 "..."
            } else if index == 3 {
                let moreEventsLabel = UILabel()
                moreEventsLabel.text = "···"
                moreEventsLabel.font = UIFont.systemFont(ofSize: 10)
                moreEventsLabel.textColor = .darkGray
                moreEventsLabel.textAlignment = .center
                moreEventsLabel.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(moreEventsLabel)

                NSLayoutConstraint.activate([
                    moreEventsLabel.topAnchor.constraint(equalTo: lastBottomAnchor, constant: spacing),
                    moreEventsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                    moreEventsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                    moreEventsLabel.heightAnchor.constraint(equalToConstant: eventHeight)
                ])
                // 不再顯示更多事件
                break
            }
        }
    }
    
}

