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
    let checkboxImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCardStyle()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCardStyle() {

        // cell 的背景是透明的，陰影才能顯示
        self.backgroundColor = .clear
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowRadius = 5
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.masksToBounds = false
    }
    
    func setupUI() {
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        checkboxImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkboxImageView)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            checkboxImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            checkboxImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkboxImageView.widthAnchor.constraint(equalToConstant: 30),
            checkboxImageView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    
    func configure(with event: CalendarEvents) {
        titleLabel.text = event.title
        checkboxImageView.image = UIImage(systemName: "checkmark.circle")
    }

}

