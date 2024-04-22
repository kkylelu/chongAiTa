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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 重用前確認清除所有 eventView
        eventViews.forEach { $0.removeFromSuperview() }
        eventViews = []
        moreEventsLabel.isHidden = true
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
        
        // 根據活動數量決定是否顯示更多
        moreEventsLabel.isHidden = events.count <= 3
        var lastBottomAnchor = dateLabel.bottomAnchor
        for (index, event) in events.prefix(3).enumerated() {
            let eventLabel = UILabel()
            eventLabel.text = event.title
            setupEventLabel(eventLabel, below: lastBottomAnchor)
            lastBottomAnchor = eventLabel.bottomAnchor
        }
        if events.count > 3 {
            setupEventLabel(moreEventsLabel, below: lastBottomAnchor)
            moreEventsLabel.text = "···"
            moreEventsLabel.isHidden = false
        }
    }
    func setupEventLabel(_ label: UILabel, below anchor: NSLayoutYAxisAnchor) {
        contentView.addSubview(label)
        label.font = UIFont.systemFont(ofSize: 10)
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
}
