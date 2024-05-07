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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupShadow()
    }

    required init?(coder: NSCoder) {
            #if DEBUG
            assertionFailure("init(coder:) has not been implemented")
            #endif
            return nil
        }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = false

    }

    
    // MARK: - Setup UI

    func setupViews() {
        nameLabel = UILabel()
        iconImageView = UIImageView()
        
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
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    
    func setupShadow() {
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 0, height: -1)
        contentView.layer.shadowRadius = 10
        contentView.layer.masksToBounds = false
        contentView.backgroundColor = .white
        
            let dynamicBackgroundColor = UIColor { (traitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return UIColor.black
                } else {
                    return UIColor.white
                }
            }
            contentView.backgroundColor = dynamicBackgroundColor
    }


    
    func configure(with name: String, icon: UIImage, date: Date) {
        nameLabel.text = name
        iconImageView.image = icon
    }
}
