//
//  GooglePlacesResponse.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/18.
//

import Foundation
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
