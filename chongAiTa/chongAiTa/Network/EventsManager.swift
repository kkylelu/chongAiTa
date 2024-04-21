//
//  EventsManager.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/21.
//

import UIKit
class EventsManager {
    static let shared = EventsManager()
    private var eventsByDate = [Date: [CalendarEvents]]()

    private init() {}

    func saveEvent(_ event: CalendarEvents) {
        let key = Calendar.current.startOfDay(for: event.date)
        if eventsByDate[key] != nil {
            eventsByDate[key]?.append(event)
        } else {
            eventsByDate[key] = [event]
        }
    }

    func loadEvents(for date: Date) -> [CalendarEvents] {
        let key = Calendar.current.startOfDay(for: date)
        return eventsByDate[key] ?? []
    }
}
