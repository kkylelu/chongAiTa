//
//  JournalData.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/13.
//

import Foundation
import Combine

class JournalData: ObservableObject {
    @Published var selectedTitle: String = ""
    @Published var showPicker: Bool = false
}

