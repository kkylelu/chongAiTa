//
//  LayerButtonType.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/5/1.
//

import UIKit

enum LayerButtonType: Int {
    case layer = 0
    case animalHospital = 1
    case park = 2
    case petStore = 3
    case currentLocation = 4

    var backgroundColor: UIColor {
        switch self {
        case .layer:
            return UIColor.B1
        case .currentLocation:
            return UIColor.B3
        case .animalHospital:
            return UIColor.B5
        case .park:
            return UIColor.B6
        case .petStore:
            return UIColor.B7
        }
    }

    var placesType: String {
        switch self {
        case .animalHospital:
            return "veterinary_care"
        case .park:
            return "park"
        case .petStore:
            return "pet_store"
        case .layer, .currentLocation:
            return ""
        }
    }

    var image: UIImage? {
        switch self {
        case .layer:
            return UIImage(systemName: "square.3.layers.3d", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium))
        case .animalHospital:
            return UIImage(systemName: "cross.case.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .medium))
        case .park:
            return UIImage(systemName: "tree.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .medium))
        case .petStore:
            return UIImage(systemName: "cart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .medium))
        case .currentLocation:
            return UIImage(systemName: "mappin.and.ellipse", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium))
        }
    }
}

