//
//  LayerButtonType.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/5/1.
//

import UIKit

enum LayerButtonType {
    case layer
    case animalHospital
    case petGrooming
    case petSupplies
    case currentLocation
    
    var backgroundColor: UIColor {
        switch self {
        case .layer:
            return UIColor.B1
        case . currentLocation:
            return UIColor.B3
        case .petSupplies:
            return UIColor.B2
        case .animalHospital:
            return UIColor.B5
        case .petGrooming:
            return UIColor.B6
        
        }
    }
    
    var image: UIImage? {
        switch self {
        case .layer:
            return UIImage(systemName: "square.3.layers.3d", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium))
        case .animalHospital:
            return UIImage(systemName: "cross.case.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .medium))
        case .petGrooming:
            return UIImage(systemName: "scissors", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .medium))
        case .petSupplies:
            return UIImage(systemName: "cart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .medium))
        case .currentLocation:
            return UIImage(systemName: "mappin.and.ellipse", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium))
        }
    }
}
