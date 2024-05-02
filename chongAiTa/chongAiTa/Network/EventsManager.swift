//
//  EventsManager.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/21.
//

import UIKit
import Dispatch

class EventsManager {
    static let shared = EventsManager()
    private var eventsByDate = [Date: [CalendarEvents]]()
    private var scheduledRecurrenceTimers: [UUID: DispatchSourceTimer] = [:]

    private init() {}

    // MARK: - Events

    // 檢查活動是否已存在避免重複新增
        func hasEvent(_ event: CalendarEvents) -> Bool {
            for (_, events) in eventsByDate {
                if events.contains(where: { $0.id == event.id }) {
                    return true
                }
            }
            return false
        }
    
    func saveEvents(_ events: [CalendarEvents]) {
        for event in events {
            let key = Calendar.current.startOfDay(for: event.date)
            if eventsByDate[key] != nil {
                eventsByDate[key]?.append(event)
            } else {
                eventsByDate[key] = [event]
            }

            // 只有在事件日期是今天或之後,才設定重複規則
            let today = Calendar.current.startOfDay(for: Date())
            if let recurrence = event.recurrence, event.date >= today {
                scheduleRecurrenceTimer(for: event, with: recurrence)
            }
        }
    }

    func scheduleRecurrenceTimer(for event: CalendarEvents, with recurrence: Recurrence) {
        let eventId = event.id
        if let existingTimer = scheduledRecurrenceTimers[eventId] {
            existingTimer.cancel()
            scheduledRecurrenceTimers[eventId] = nil
        }

        let interval: TimeInterval
        switch recurrence {
        case .daily:
            interval = 86400.0 // 每天
        case .weekly:
            interval = 604800.0 // 每週
        case .monthly:
            interval = 2629800.0 // 每月
        case .yearly:
            interval = 31557600.0 // 每年
        }

        let timer = DispatchSource.makeTimerSource(queue: .main)
        let nextInterval = getNextInterval(start: event.date, interval: interval)
        timer.schedule(deadline: .now() + nextInterval, repeating: interval)
        timer.setEventHandler { [weak self] in
            self?.createRecurringEvent(event)
        }
        scheduledRecurrenceTimers[eventId] = timer
        timer.resume()
    }

    func createRecurringEvent(_ event: CalendarEvents) {
        guard let recurrence = event.recurrence else {
            return
        }

        var nextDate = event.date

        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: nextDate)

        switch recurrence {
        case .daily:
            components.day = (components.day ?? 0) + 1
        case .weekly:
            components.day = (components.day ?? 0) + 7
        case .monthly:
            components.month = (components.month ?? 0) + 1
        case .yearly:
            components.year = (components.year ?? 0) + 1
        }

        nextDate = calendar.date(from: components) ?? nextDate

        let newEvent = CalendarEvents(
            id: UUID(),
            title: event.title,
            date: nextDate,
            activity: event.activity,
            content: event.content,
            image: event.image,
            cost: event.cost,
            recurrence: event.recurrence
        )

        let key = Calendar.current.startOfDay(for: nextDate)
        if eventsByDate[key] != nil {
            eventsByDate[key]?.append(newEvent)
        } else {
            eventsByDate[key] = [newEvent]
        }
    }
    
    // 計算下一次事件的間隔
    private func getNextInterval(start: Date, interval: TimeInterval) -> TimeInterval {
        let now = Date()
        if start < now {
            let elapsed = now.timeIntervalSince(start)
            let next = ceil(elapsed / interval) * interval
            return next - elapsed
        } else {
            return start.timeIntervalSince(now)
        }
    }

    func loadEvent(with id: UUID) -> CalendarEvents? {
        for (_, events) in eventsByDate {
            if let event = events.first(where: { $0.id == id }) {
                return event
            }
        }
        return nil
    }
    
    func loadEvents(from startDate: Date, to endDate: Date) -> [CalendarEvents] {
        var allEvents: [CalendarEvents] = []
        
        for (_, events) in eventsByDate {
            for event in events {
                if event.date >= startDate && event.date <= endDate {
                    allEvents.append(event)
                }
                
                if let recurrence = event.recurrence {
                    var nextDate = event.date
                    
                    while nextDate <= endDate {
                        switch recurrence {
                        case .daily:
                            nextDate = Calendar.current.date(byAdding: .day, value: 1, to: nextDate)!
                        case .weekly:
                            nextDate = Calendar.current.date(byAdding: .day, value: 7, to: nextDate)!
                        case .monthly:
                            nextDate = Calendar.current.date(byAdding: .month, value: 1, to: nextDate)!
                        case .yearly:
                            nextDate = Calendar.current.date(byAdding: .year, value: 1, to: nextDate)!
                        }
                        
                        if nextDate > startDate && nextDate <= endDate {
                            let newEvent = CalendarEvents(
                                id: event.id,
                                title: event.title,
                                date: nextDate,
                                activity: event.activity,
                                content: event.content,
                                image: event.image,
                                cost: event.cost,
                                recurrence: event.recurrence
                            )
                            allEvents.append(newEvent)
                        }
                    }
                }
            }
        }
        
        return allEvents
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
    
    func deleteEvent(_ event: CalendarEvents) {
        let key = Calendar.current.startOfDay(for: event.date)
        if var events = eventsByDate[key] {
            events.removeAll { $0.id == event.id }
            eventsByDate[key] = events
        }
        FirestoreService.shared.deleteEvent(event) { result in
            switch result {
            case .success():
                print("成功刪除本機和 firebase 資料")
            case .failure(let error):
                print("無法刪除 firebase 資料: \(error)")
            }
        }
    }
    
    // MARK: - Costs
    
    func getAllCosts() -> [(eventId: UUID, cost: Double)] {
        var allCosts: [(eventId: UUID, cost: Double)] = []
        for (_, events) in eventsByDate {
            for event in events where event.cost != nil {
                allCosts.append((event.id, event.cost!))
            }
        }
        return allCosts
    }
    
    func getCostsForLastWeek() -> [(eventId: UUID, cost: Double)] {
        var costsForLastWeek: [(eventId: UUID, cost: Double)] = []
        
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        var daysToLastMonday = 0
        
        if weekday == 1 {
            daysToLastMonday = -6
        } else {
            daysToLastMonday = -weekday + 2
        }
        
        let lastMonday = calendar.date(byAdding: .day, value: daysToLastMonday, to: today)!
        let lastSunday = calendar.date(byAdding: .day, value: 6, to: lastMonday)!
        let lastWeekEnd = calendar.date(byAdding: .day, value: 1, to: lastSunday)!
        
        let eventsForLastWeek = loadEvents(from: lastMonday, to: lastWeekEnd)
        
        for event in eventsForLastWeek where event.cost != nil {
            costsForLastWeek.append((event.id, event.cost!))
        }
        
        return costsForLastWeek
    }

    func getCostsForCurrentMonth() -> [(eventId: UUID, cost: Double)] {
        var costsForCurrentMonth: [(eventId: UUID, cost: Double)] = []
        
        let calendar = Calendar.current
        let today = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
        let endOfMonthDate = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        let endOfMonth = calendar.startOfDay(for: endOfMonthDate)
        
        let eventsForCurrentMonth = loadEvents(from: startOfMonth, to: endOfMonth)
        
        for event in eventsForCurrentMonth where event.cost != nil {
            costsForCurrentMonth.append((event.id, event.cost!))
        }
        
        return costsForCurrentMonth
    }

}

extension CalendarEvents: Hashable {
    static func == (lhs: CalendarEvents, rhs: CalendarEvents) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
