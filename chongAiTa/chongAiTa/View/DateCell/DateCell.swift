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
        // (DateCell 總高度 - datalabel 高度 - 間隔數量) / (活動數量)
        let eventHeight: CGFloat = (contentView.bounds.height - dateLabelHeight - CGFloat(events.count - 1) * 2) / CGFloat(events.count)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            dateLabel.heightAnchor.constraint(equalToConstant: dateLabelHeight)
        ])
        
        var lastBottomAnchor = dateLabel.bottomAnchor
        for (index, event) in events.enumerated() {
            if index < 4 {
                let eventView = UIView()
                eventView.backgroundColor = UIColor.B3
                eventView.layer.cornerRadius = 5
                eventView.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(eventView)
                
                NSLayoutConstraint.activate([
                    eventView.topAnchor.constraint(equalTo: lastBottomAnchor, constant: 2),
                    eventView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                    eventView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                    eventView.heightAnchor.constraint(equalToConstant: eventHeight)
                ])
                lastBottomAnchor = eventView.bottomAnchor
                eventViews.append(eventView)
            } else {
                break
            }
        }
    }
}

