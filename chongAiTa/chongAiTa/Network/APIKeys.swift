//
//  APIKeys.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/15.
//

import Foundation

class APIKeys {
    let dictionary: NSDictionary
    
    init(resourceName: String) {
        guard let filePath = Bundle.main.path(forResource: resourceName, ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath) else {
            fatalError("Could not find the file '\(resourceName)' plist. Please follow these steps to generate API Keys: https://github.com/SonmezYigithan/GameListingApp-iOS#create-api-keys")
        }
        dictionary = plist
        
        // Check if OPENAI_AUTHORIZATION is nil or empty
        if let openAiAPIKey = dictionary["OPENAI_AUTHORIZATION"] as? String, openAiAPIKey.isEmpty {
            fatalError("OPENAI_AUTHORIZATION is empty. Please follow these steps to generate API Keys: https://github.com/SonmezYigithan/GameListingApp-iOS#create-api-keys")
        }
    }
    
    var openAiAPIKey: String {
        dictionary["OPENAI_AUTHORIZATION"] as? String ?? ""
    }
    
    var googleMapsAPIKey: String {
            dictionary["GOOGLEMAPS_AUTHORIZATION"] as? String ?? ""
        }
}
