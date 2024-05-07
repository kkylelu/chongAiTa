//
//  JournalingSuggestionsModel.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/13.
//

import UIKit
import CoreLocation

#if !targetEnvironment(simulator)
import JournalingSuggestions
#endif

struct JournalingSuggestionContent {
    #if !targetEnvironment(simulator)
    var podcast: JournalingSuggestion.Podcast
    var photo: JournalingSuggestion.Photo
    var livePhoto: JournalingSuggestion.LivePhoto
    var contact: JournalingSuggestion.Contact
    var song: JournalingSuggestion.Song
    #endif
}

struct UIImageWrapper {
    let image: UIImage
}

struct IdentifiableLocation: Identifiable {
    let id = UUID()
    #if !targetEnvironment(simulator)
    let location: JournalingSuggestion.Location
    #endif
}

