//
//  PetDetailTableViewCell.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/25.
//

import UIKit

protocol PetDetailTableViewCellDelegate: AnyObject {
    func didTapButton(_ sender: PetDetailTableViewCell)
}

class PetDetailTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "PetDetailTableViewCell"
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var petDetailButton: UIButton!
    
    weak var delegate: PetDetailTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        petDetailButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }
    
    // MARK: - Setup UI
    func setupUI() {
        contentView.backgroundColor = .systemGray6
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        petDetailButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            petDetailButton.leadingAnchor.constraint(equalTo: valueLabel.trailingAnchor, constant: 8),
            petDetailButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            petDetailButton.centerYAnchor.constraint(equalTo: valueLabel.centerYAnchor),
            petDetailButton.heightAnchor.constraint(equalToConstant: 16),
            petDetailButton.widthAnchor.constraint(equalToConstant: 16)
        ])
        
        titleLabel.widthAnchor.constraint(equalTo: valueLabel.widthAnchor).isActive = true
    }
    
    
    func configure(with item: PetDetailItem, pet: Pet) {
        
        iconImageView.image = item.icon
        iconImageView.tintColor = .black
        
        titleLabel.text = item.title
        titleLabel.textAlignment = .left
        
        valueLabel.textAlignment = .right
        valueLabel.textColor = UIColor.B1
        
        petDetailButton.tintColor = .lightGray
        
        switch item {
        case .name:
            valueLabel.text = pet.name
        case .gender:
            valueLabel.text = pet.gender.rawValue
        case .type:
            valueLabel.text = pet.type.displayName
        case .breed:
            valueLabel.text = pet.breed ?? "未知"
        case .birthday:
            if let date = pet.birthday {
                valueLabel.text = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
            } else {
                valueLabel.text = "未設定"
            }
        case .joinDate:
            if let date = pet.joinDate {
                valueLabel.text = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
            } else {
                valueLabel.text = "未設定"
            }
        case .weight:
            if let weight = pet.weight {
                valueLabel.text = "\(weight) 公斤"
            } else {
                valueLabel.text = "未設定"
            }
        case .isNeutered:
            valueLabel.text = pet.isNeutered ? "已結紮" : "未結紮"
        }
    }
    @objc func buttonTapped(_ sender: UIButton) {
            delegate?.didTapButton(self)
        }
}

