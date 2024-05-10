//
//  SetupBackgroundColor.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/5/4.
//

import UIKit

extension UIViewController {
    func applyDynamicBackgroundColor(lightModeColor: UIColor, darkModeColor: UIColor) {
        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor { traitCollection -> UIColor in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return darkModeColor
                default:
                    return lightModeColor
                }
            }
        } else {
            view.backgroundColor = lightModeColor
        }
    }
}
