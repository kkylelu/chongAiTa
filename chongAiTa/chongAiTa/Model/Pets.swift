//
//  Pets.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/25.
//

import Foundation

struct Pets {
    var petsArray: [Pet]
}

struct Pet: Codable {
    var id: UUID = UUID()
    var image: String?
    var imageUrl: [String]
    var name: String
    var gender: Gender
    var type: PetType
    var breed: String?
    var birthday: Date?
    var joinDate: Date?
    var weight: Double?
    var isNeutered: Bool
    
    enum Gender: String, CaseIterable, Codable {
        case male = "男孩"
        case female = "女孩"
        case none = "不公開"
    }

    enum PetType: Int, CaseIterable, Codable {
        case dog = 0
        case cat = 1
        
        var displayName: String {
            switch self {
            case .dog:
                return "汪星人"
            case .cat:
                return "喵星人"
            }
        }
    }
}
