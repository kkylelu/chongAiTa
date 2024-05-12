//
//  NavigationTitle.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/5/1.
//

import UIKit
enum NavigationTitle {
    case chatbot
    case pet
    case costChart
    case calendarDate
    case map
    case MemeGenerator
    
    var title: String {
        switch self {
        case .chatbot:
            return "AI 寵物助理"
        case .pet:
            return "毛孩資料"
        case .costChart:
            return "花費圖表"
        case .calendarDate:
            return "當日活動列表"
        case .map:
            return "寵物地圖"
        case .MemeGenerator:
            return "毛孩貼圖"
            
        }
    }
    
    var font: UIFont {
        return UIFont.systemFont(ofSize: 20)
    }
    
    var textColor: UIColor {
        return UIColor.white
    }
}

extension UIViewController {
    func setNavigationTitle(_ title: NavigationTitle) {
        let titleLabel = UILabel()
        titleLabel.text = title.title
        titleLabel.textColor = title.textColor
        titleLabel.font = title.font
        self.navigationItem.titleView = titleLabel
    }
}
