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
    let iconImageView = UIImageView()
    private var selectedDate: Date?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
            #if DEBUG
            assertionFailure("init(coder:) has not been implemented")
            #endif
            return nil
        }

    func setupUI() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.layer.cornerRadius = 15
        iconImageView.clipsToBounds = true
        iconImageView.contentMode = .scaleAspectFill

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .black

        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),

            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(with title: String, icon: UIImage, date: Date) {
        titleLabel.text = title
        iconImageView.image = icon
        selectedDate = date
    }
}

