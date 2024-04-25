//
//  PetDetailItem.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/25.
//

import UIKit
enum PetDetailItem {
    case name
    case gender
    case type
    case breed
    case birthday
    case joinDate
    case weight
    case isNeutered
    
    var icon: UIImage? {
        switch self {
        case .name:
            return UIImage(systemName: "person.circle")
        case .gender:
            return UIImage(systemName: "tag")
        case .type:
            return UIImage(systemName: "pawprint.circle")
        case .breed:
            return UIImage(systemName: "doc.richtext")
        case .birthday:
            return UIImage(systemName: "calendar")
        case .joinDate:
            return UIImage(systemName: "house")
        case .weight:
            return UIImage(systemName: "scalemass")
        case .isNeutered:
            return UIImage(systemName: "scissors")
        }
    }
    
    static func forIndexPath(_ indexPath: IndexPath) -> PetDetailItem {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            return .name
        case (0, 1):
            return .gender
        case (0, 2):
            return .type
        case (0, 3):
            return .breed
        case (1, 0):
            return .birthday
        case (1, 1):
            return .joinDate
        case (1, 2):
            return .weight
        case (1, 3):
            return .isNeutered
        default:
            fatalError("Invalid indexPath for PetDetailItem")
        }
    }
    
    
    var title: String {
        switch self {
        case .name:
            return "名字"
        case .gender:
            return "性別"
        case .type:
            return "寵物類型"
        case .breed:
            return "品種"
        case .birthday:
            return "生日"
        case .joinDate:
            return "到家日"
        case .weight:
            return "體重"
        case .isNeutered:
            return "結紮狀態"
        }
    }
}
