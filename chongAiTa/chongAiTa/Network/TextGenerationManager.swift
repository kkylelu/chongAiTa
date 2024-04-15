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
            ["role": "system", "content": "你是一個寵物日記摘要專家，請以親切的語氣，幫寵物主人回顧這個月紀錄的寵物日記內容，用寵物主人的口吻敘述成一篇小故事。請把特定時間例如「今天」、「晚上」，取代為「有一天」、「某天晚上」這樣的敘述。請用台灣繁體中文回覆。請限制在 200 個 token 內說完故事。"],
            ["role": "user", "content": journalTexts]
        ]
        let parameters: Parameters = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "max_tokens": 200
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
