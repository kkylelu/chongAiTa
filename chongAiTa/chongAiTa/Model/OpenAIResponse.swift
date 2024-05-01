//
//  OpenAIResponse.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/15.
//

import Foundation
struct OpenAIResponse: Codable {
    struct Choice: Codable {
        let message: Message
    }
    struct Message: Codable {
        let content: String
    }
    let choices: [Choice]
}
