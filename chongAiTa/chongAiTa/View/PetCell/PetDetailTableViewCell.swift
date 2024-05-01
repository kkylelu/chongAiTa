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
    
    var iconImageView = UIImageView()
    var titleLabel = UILabel()
    var valueLabel = UILabel()
    var petDetailButton = UIButton(type: .system)
    
    weak var delegate: PetDetailTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    func setupUI() {
        contentView.backgroundColor = .systemGray6
        
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        valueLabel.font = UIFont.systemFont(ofSize: 18)
        
        let image = UIImage(systemName: "chevron.right")
        petDetailButton.setImage(image, for: .normal)
        petDetailButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        contentView.addSubview(petDetailButton)
        
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
            titleLabel.widthAnchor.constraint(equalToConstant: 80),
            
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: petDetailButton.leadingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            petDetailButton.leadingAnchor.constraint(equalTo: valueLabel.trailingAnchor, constant: 8),
            petDetailButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            petDetailButton.centerYAnchor.constraint(equalTo: valueLabel.centerYAnchor),
            petDetailButton.heightAnchor.constraint(equalToConstant: 16),
            petDetailButton.widthAnchor.constraint(equalToConstant: 16)
        ])
        valueLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
    }
    
    func formatDate(_ date: Date?, format: String) -> String {
        guard let date = date else {
            return "未設定日期"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh_Hant_TW")
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: date)
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
                valueLabel.text = formatDate(pet.birthday, format: "yyyy 年 M 月 d 日")
            } else {
                valueLabel.text = "未設定"
            }
        case .joinDate:
            if let date = pet.joinDate {
                valueLabel.text = formatDate(pet.joinDate, format: "yyyy 年 M 月 d 日")
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

