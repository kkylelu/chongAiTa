//
//  CalendarEvents.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/20.
//

import UIKit

struct CalendarEvents {
    var title: String
    var date: Date
    var activity: DefaultActivity
    var content: String?
    var image: UIImage?
    
    init(title: String, date: Date, activity: DefaultActivity, content: String? = nil, image: UIImage? = nil) {
        self.title = title
        self.date = date
        self.activity = activity
        self.content = content
        self.image = image
    }
}

struct DefaultActivity {
    var category: ActivityCategory
    var date: Date
}


enum ActivityCategory: Int {
    case food = 0
    case medication = 1
    case walk = 2
    // 後續可增加更多類別
    
    var displayName: String {
        switch self {
        case .food:
            return "餵食"
        case .medication:
            return "看醫生"
        case .walk:
            return "散步"
        }
    }
}
