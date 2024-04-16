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
        let urlEndpoint = OpenAINetworkHelper.shared.baseURL + "chat/completions"
        let journalTexts = journals.map { $0.body }.joined(separator: "\n")
        let messages = [
            ["role": "system", "content": "You are a professional pet diary summarizer. Please, with a warm and friendly tone, help pet owners reflect on their pets' diary entries from this month and transform these records into a complete short story using the pet owner's voice. In the story, use vague terms like 'one day' or 'one evening' instead of specific times to broaden the story's universality. Ensure that the story is complete within a 200 token limit, with no cliffhangers or unfinished sentences. The story should include a clear beginning, development, and conclusion to ensure semantic completeness. Please respond in Traditional Chinese (Taiwan)."],
            ["role": "user", "content": journalTexts]
        ]
        let parameters: Parameters = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
        ]

        NetworkManager.shared.request(url: urlEndpoint, method: .post, parameters: parameters, headers: OpenAINetworkHelper.shared.headers()) { (result: Result<OpenAIResponse, Error>) in
            switch result {
            case .success(let response):
                let summary = response.choices.first?.message.content ?? ""
                completion(.success(summary))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
