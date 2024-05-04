//
//  User.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/5/4.
//

import Foundation

struct User: Codable {
    var id: UUID = UUID()
    var appleID: String?
    var name: String
    var email: String
    var pets: [UUID]
    var journals: [UUID]
    var calendarEvents: [UUID]

    init(id: UUID = UUID(), appleID: String?, name: String, email: String, pets: [UUID] = [], journals: [UUID] = [], calendarEvents: [UUID] = []) {
        self.id = id
        self.appleID = appleID
        self.name = name
        self.email = email
        self.pets = pets
        self.journals = journals
        self.calendarEvents = calendarEvents
    }
}
