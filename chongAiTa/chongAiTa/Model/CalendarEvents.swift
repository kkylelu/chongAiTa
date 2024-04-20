//
//  CalendarEvents.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/20.
//

import Foundation
struct CalendarEvents {
    var id: UUID
    var title: String
    var type: Int
    var date: Date

    init(id: UUID, title: String, type: Int, date: Date) {
        self.id = id
        self.title = title
        self.type = type
        self.date = date
    }
}
