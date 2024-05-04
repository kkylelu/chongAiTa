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
            // 對於 iOS 13 以下版本，可以設定一個默認顏色
            view.backgroundColor = lightModeColor
        }
    }
}
