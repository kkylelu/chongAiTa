//
//  UserProfileCollectionViewCell.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/5/3.
//

import UIKit

protocol UserProfileCollectionViewCellDelegate: AnyObject {
    func didTapButton(in cell: UserProfileCollectionViewCell)
}

class UserProfileCollectionViewCell: UICollectionViewCell {
    
    var iconImageView = UIImageView()
    var titleLabel = UILabel()
    var actionButton = UIButton(type: .system)

    weak var delegate: UserProfileCollectionViewCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        contentView.backgroundColor = .white

        titleLabel.font = UIFont.systemFont(ofSize: 18)
        
        let buttonImage = UIImage(systemName: "chevron.right")
        actionButton.setImage(buttonImage, for: .normal)
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(actionButton)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -8),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            actionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 24),
            actionButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with icon: UIImage?, title: String) {
        iconImageView.image = icon
        iconImageView.tintColor = UIColor.B1
        
        titleLabel.text = title
        
        actionButton.tintColor = .lightGray
    }
    
    // MARK: - Action
    @objc private func buttonTapped() {
        delegate?.didTapButton(in: self)
    }
    
   
}

