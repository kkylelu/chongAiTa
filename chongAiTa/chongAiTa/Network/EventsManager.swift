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
    
    func updateEvent(_ updatedEvent: CalendarEvents) {
        let key = Calendar.current.startOfDay(for: updatedEvent.date)
        if var events = eventsByDate[key] {
            if let index = events.firstIndex(where: { $0.id == updatedEvent.id }) {
                events[index] = updatedEvent
                eventsByDate[key] = events
                print("Event with ID \(updatedEvent.id) updated.")
            } else {
                print("No event found with ID \(updatedEvent.id) to update.")
            }
        }
    }

}
