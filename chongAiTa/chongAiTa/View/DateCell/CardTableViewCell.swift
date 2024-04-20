//
//  CardTableViewCell.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/20.
//

// CardTableViewCell.swift

import UIKit

class CardTableViewCell: UITableViewCell {
    let titleLabel = UILabel()
    let dateLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {

        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
        
        titleLabel.textColor = .black
        dateLabel.textColor = .darkGray
    }
    
    func configure(with title: String, date: Date) {
        titleLabel.text = title
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateLabel.text = dateFormatter.string(from: date)
    }
}

