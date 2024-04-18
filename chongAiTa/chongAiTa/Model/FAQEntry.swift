//
//  FAQEntry.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/18.
//

import Foundation

struct FAQCategory: Codable {
    let health: [FAQEntry]
    let nutrition: [FAQEntry]
    let care: [FAQEntry]
}

struct FAQEntry: Codable {
    let question: String
    let answer: String
}

