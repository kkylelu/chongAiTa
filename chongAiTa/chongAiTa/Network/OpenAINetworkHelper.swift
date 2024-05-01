//
//  OpenAINetworkHelper.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/15.
//

import Foundation
import Alamofire

class OpenAINetworkHelper {
    static let shared = OpenAINetworkHelper()
    private let apiKeys = APIKeys(resourceName: "API-Keys")
    let baseURL = "https://api.openai.com/v1/"

    func headers() -> HTTPHeaders {
        ["Authorization": "Bearer \(apiKeys.openAiAPIKey)",
         "Content-Type": "application/json"]
    }
}
