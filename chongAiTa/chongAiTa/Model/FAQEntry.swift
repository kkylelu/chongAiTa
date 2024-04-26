//
//  FAQEntry.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/18.
//

import Foundation

struct FAQCategory: Codable {
    let id: String?
    let health: [FAQEntry]
    let nutrition: [FAQEntry]
    let care: [FAQEntry]
    
    init(id: String? = nil, health: [FAQEntry], nutrition: [FAQEntry], care: [FAQEntry]) {
        self.id = id
        self.health = health
        self.nutrition = nutrition
        self.care = care
    }
}

struct FAQEntry: Codable {
    let question: String
    let answer: String
}

