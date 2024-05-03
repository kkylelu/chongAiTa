//
//  UIColorHexCode.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/14.
//

import UIKit
import SwiftUI

private enum STColor: String {
    case B1 = "#F59245" // 主色
    case B2 = "#fcdbc1" // 淺橘
    case B3 = "#a3612e" // 咖啡色
    case B4 = "#311D0E" // 深咖啡
    case B5 = "#E36588" // 粉紅
    case B6 = "#8A9B68" // 茶綠
    case B7 = "#9AC4F8" // 淺藍
    case B8 = "#FDE9DA" // 皮膚色
}

extension UIColor {

    static let B1 = UIColor.hexStringToUIColor(hex: STColor.B1.rawValue)
    static let B2 = UIColor.hexStringToUIColor(hex: STColor.B2.rawValue)
    static let B3 = UIColor.hexStringToUIColor(hex: STColor.B3.rawValue)
    static let B4 = UIColor.hexStringToUIColor(hex: STColor.B4.rawValue)
    static let B5 = UIColor.hexStringToUIColor(hex: STColor.B5.rawValue)
    static let B6 = UIColor.hexStringToUIColor(hex: STColor.B6.rawValue)
    static let B7 = UIColor.hexStringToUIColor(hex: STColor.B7.rawValue)

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

extension Color {
    init(uiColor: UIColor) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        self.init(red: Double(red), green: Double(green), blue: Double(blue), opacity: Double(alpha))
    }
}
