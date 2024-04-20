//
//  CalendarEvents.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/20.
//

import Foundation

struct CalendarEvents {
    var title: String
    var date: Date
    var activity: DefaultActivity

    init(title: String, date: Date, activity: DefaultActivity) {
        self.title = title
        self.date = date
        self.activity = activity
    }
}

struct DefaultActivity {
    var category: ActivityCategory
    var date: Date
}


enum ActivityCategory: Int {
    case food = 0
    case medication = 1
    case exercise = 2
    // 後續可增加更多類別

    var displayName: String {
        switch self {
        case .food:
            return "餵食"
        case .medication:
            return "看醫生"
        case .exercise:
            return "運動"
        }
    }
}
