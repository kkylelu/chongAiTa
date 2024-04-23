//
//  CalendarEvents.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/20.
//

import UIKit

struct CalendarEvents {
    var id: UUID
    var title: String
    var date: Date
    var activity: DefaultActivity
    var content: String?
    var image: UIImage?
    var cost: Double?
    var recurrence: Recurrence?
    
    init(id: UUID = UUID(), title: String, date: Date, activity: DefaultActivity, content: String? = nil, image: UIImage? = nil, cost: Double? = nil, recurrence: Recurrence? = nil) {
        self.id = id
        self.title = title
        self.date = date
        self.activity = activity
        self.content = content
        self.image = image
        self.cost = cost
        self.recurrence = recurrence
    }
    
}

enum Recurrence {
    case daily
    case weekly
    case monthly
    case yearly
}

struct DefaultActivity {
    var category: ActivityCategory
    var date: Date
}


enum ActivityCategory: Int {
    case food = 0
    case medication = 1
    case shower = 2
    // 後續可增加更多類別
    
    var displayName: String {
        switch self {
        case .food:
            return "餵食"
        case .medication:
            return "看醫生"
        case .shower:
            return "美容洗澡"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .food:
            return UIImage(named: "foodIcon")
        case .medication:
            return UIImage(named: "medicationIcon")
        case .shower:
            return UIImage(named: "exerciseIcon")
        }
    }
}
