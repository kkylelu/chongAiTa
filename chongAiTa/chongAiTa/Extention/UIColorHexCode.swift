//
//  UIColorHexCode.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/14.
//

import UIKit

private enum STColor: String {
    case B1 = "#F59245"
    case B2 = "#fcdbc1"
    case B3 = "#a3612e"
}

extension UIColor {

    static let B1 = UIColor.hexStringToUIColor(hex: STColor.B1.rawValue)
    static let B2 = UIColor.hexStringToUIColor(hex: STColor.B2.rawValue)
    static let B3 = UIColor.hexStringToUIColor(hex: STColor.B2.rawValue)

    static func hexStringToUIColor(hex: String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if (cString.count) != 6 {
            return .gray
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
