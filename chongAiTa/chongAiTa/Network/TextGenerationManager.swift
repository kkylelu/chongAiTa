//
//  TextGenerationManager.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/15.
//

import Foundation
import Alamofire

class TextGenerationManager {
    static let shared = TextGenerationManager()

    func generateSummary(from journals: [Journal], completion: @escaping (Result<String, Error>) -> Void) {
        let urlEndpoint = OpenAINetworkHelper.shared.baseURL + "completions"
        let journalTexts = journals.map { $0.body }.joined(separator: "\n")
        let parameters: Parameters = [
            "prompt": "Say this is a test", //Summarize the following journal entries:\n\(journalTexts)
            "max_tokens": 100,
            "model": "gpt-3.5-turbo-instruct"
        ]

        NetworkManager.shared.request(url: urlEndpoint, method: .post, parameters: parameters, headers: OpenAINetworkHelper.shared.headers()) { (result: Result<OpenAIResponse, Error>) in
            switch result {
            case .success(let response):
                let summary = response.choices.first?.text ?? ""
                completion(.success(summary))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

struct OpenAIResponse: Codable {
    struct Choice: Codable {
        let text: String
    }
    let choices: [Choice]
}
