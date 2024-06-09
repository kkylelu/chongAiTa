//
//  CalendarViewModel.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/5/20.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class CalendarViewModel {
    var currentMonthDate = Date()
    var calendarEventsArray: [CalendarEvents] = []
    var eventsListener: ListenerRegistration?
    var daysInMonth: Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentMonthDate)!
        return range.count
    }
    var firstWeekdayOfMonth: Int {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: currentMonthDate)
        components.day = 1
        let firstDayOfMonthDate = calendar.date(from: components)!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonthDate)
        return firstWeekday - 2
    }
    
    var updateView: (() -> Void)?
    
    func loadEventsForCurrentMonth() {
        let startOfMonth = firstOfMonth()
        let endOfMonth = Calendar.current.date(byAdding: .month, value: 1, to: startOfMonth)!
        
        if let currentUser = Auth.auth().currentUser {
            let userId = currentUser.uid
            
            FirestoreService.shared.fetchEvents(userId: userId, from: startOfMonth, to: endOfMonth) { [weak self] result in
                switch result {
                case .success(let events):
                    DispatchQueue.main.async {
                        events.forEach { event in
                            if !EventsManager.shared.hasEvent(event) {
                                EventsManager.shared.saveEvents([event])
                            }
                        }
                        self?.updateView?()
                    }
                case .failure(let error):
                    print("從 Firestore 獲取活動時出錯：\(error)")
                }
            }
        }
    }
    
    func goToPreviousMonth() {
        if let prevMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: currentMonthDate) {
            currentMonthDate = prevMonthDate
            updateView?()
        }
    }
    
    func goToNextMonth() {
        if let nextMonthDate = Calendar.current.date(byAdding: .month, value: 1, to: currentMonthDate) {
            currentMonthDate = nextMonthDate
            updateView?()
        }
    }
    
    func titleForCurrentMonth() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy 年 MM 月"
        return formatter.string(from: currentMonthDate)
    }
    
    func firstOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: currentMonthDate)
        return calendar.date(from: components)!
    }
}

