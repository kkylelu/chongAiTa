//
//  GooglePlacesResponse.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/18.
//

import Foundation

// MARK: - 舊版 Places API 模型
struct Place: Codable {
    let geometry: Geometry
    let name: String
    let vicinity: String
}

struct Geometry: Codable {
    let location: Location
}

struct Location: Codable {
    let lat: Double
    let lng: Double
}

struct PlacesResponse: Codable {
    let results: [Place]
}

// MARK: - 新版 Places API (New) 模型
struct NewPlacesResponse: Codable {
    let places: [NewPlace]?
}

struct NewPlace: Codable {
    let id: String
    let displayName: DisplayName?
    let location: NewLocation
    let formattedAddress: String?
    let types: [String]?
    let rating: Double?
    let internationalPhoneNumber: String?
}

struct DisplayName: Codable {
    let text: String
    let languageCode: String?
}

struct NewLocation: Codable {
    let latitude: Double
    let longitude: Double
}
