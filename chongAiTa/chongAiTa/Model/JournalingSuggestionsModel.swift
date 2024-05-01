//
//  JournalingSuggestionsModel.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/13.
//

import UIKit
import CoreLocation
import JournalingSuggestions

struct JournalingSuggestionContent {
    var podcast: JournalingSuggestion.Podcast
    var photo: JournalingSuggestion.Photo
    var livePhoto: JournalingSuggestion.LivePhoto
    var contact: JournalingSuggestion.Contact
    var song: JournalingSuggestion.Song
}

struct UIImageWrapper {
    let image: UIImage
}

struct IdentifiableLocation: Identifiable {
    let id = UUID()
    let location: JournalingSuggestion.Location
}

