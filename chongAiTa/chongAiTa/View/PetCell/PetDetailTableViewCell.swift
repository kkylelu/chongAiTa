//
//  PetDetailTableViewCell.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/25.
//

import UIKit

class PetDetailTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "PetDetailTableViewCell"
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var petDetailbutton: UIButton!
    
    func configure(with item: PetDetailItem, pet: Pet) {
        iconImageView.image = item.icon
        titleLabel.text = item.title
        
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
    
    
}

