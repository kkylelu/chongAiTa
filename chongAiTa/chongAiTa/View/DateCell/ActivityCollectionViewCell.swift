//
//  ActivityCollectionViewCell.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/30.
//

import UIKit

class ActivityCollectionViewCell: UICollectionViewCell {
    var nameLabel: UILabel!
    var iconImageView: UIImageView!
    var dateLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        nameLabel = UILabel()
        iconImageView = UIImageView()
        
        contentView.layer.borderWidth = 1
//        contentView.layer.cornerRadius = 10
//        contentView.layer.masksToBounds = true
//        
//        contentView.layer.shadowOpacity = 0.2
//        contentView.layer.shadowRadius = 5
//        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        contentView.layer.shadowColor = UIColor.black.cgColor
//        contentView.layer.masksToBounds = false
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(iconImageView)
        
        NSLayoutConstraint.activate([
        iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
        iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        iconImageView.widthAnchor.constraint(equalToConstant: 40),
        iconImageView.heightAnchor.constraint(equalToConstant: 40),
        
        nameLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
        nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
        nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with name: String, icon: UIImage, date: Date) {
        nameLabel.text = name
        iconImageView.image = icon
    }
}
