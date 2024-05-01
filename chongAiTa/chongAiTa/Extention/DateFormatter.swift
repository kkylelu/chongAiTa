//
//  DateFormatter.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/25.
//

import UIKit
extension DateFormatter {
    static func date(from string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string)
    }
}
