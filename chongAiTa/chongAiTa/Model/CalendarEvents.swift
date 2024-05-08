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
    var imageName: String?
    var cost: Double?
    var recurrence: Recurrence?
    
    init(id: UUID = UUID(), title: String, date: Date, activity: DefaultActivity, content: String? = nil, imageName: String? = nil, cost: Double? = nil, recurrence: Recurrence? = nil) {
        self.id = id
        self.title = title
        self.date = date
        self.activity = activity
        self.content = content
        self.imageName = imageName
        self.cost = cost
        self.recurrence = recurrence
    }
    
}

enum Recurrence: String {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
}

struct DefaultActivity {
    var category: ActivityCategory
    var date: Date
}


enum ActivityCategory: Int {
    case food = 0
    case medication = 1
    case shower = 2
    case toy = 3
    case walk = 4
    case others = 5
    
    var displayName: String {
        switch self {
        case .food:
            return "餵食"
        case .medication:
            return "看醫生"
        case .shower:
            return "美容洗澡"
        case .toy:
            return "買玩具"
        case .walk:
            return "散步"
        case .others:
            return "其他"
        }
    }
    
    var iconName: String {
        switch self {
        case .food: return "Feed"
        case .medication: return "Vet Visit"
        case .shower: return "Groom"
        case .toy: return "Toy Shopping"
        case .walk: return "Walk"
        case .others: return "Others"
        }
    }
}
