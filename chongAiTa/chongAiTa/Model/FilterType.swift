//
//  FilterType.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/5/13.
//

import Foundation
enum FilterType: String, CaseIterable {
    case speedline
    case notice
    case shine
    case bowTie
    case dizzy
    case goldenNecklace
    case glasses
    case heart
    case questionMark
    case shockEyes
    case shyFace
    case skyAnime
    case sleepy
    case sparklyEyes
    case sunglasses
    case sweatDrip
    
    var overlayImageName: String {
        return self.rawValue
    }

    var filterName: String {
        return self.rawValue.capitalized
    }
}
