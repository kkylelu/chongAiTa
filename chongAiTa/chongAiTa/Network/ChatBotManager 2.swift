//
//  ChatBotManager.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/18.
//

import Foundation
import Alamofire

class ChatBotManager {
    static let shared = ChatBotManager()

    func sendChatMessage(message: String, completion: @escaping (Result<String, Error>) -> Void) {
        let urlEndpoint = OpenAINetworkHelper.shared.baseURL + "chat/completions"
        let messages = [
            ["role": "system", "content": "You are now a veterinarian, specializing in answering users' questions about their pets, such as dietary advice and preliminary symptom diagnosis. Please respond in a conversational form, keeping each reply concise, limited to a maximum of three sentences. Answer with a friendly tone and occasionally include an appropriate emoji based on the context (no more than one). All responses should be in Traditional Chinese (Taiwan)."],
            ["role": "user", "content": message]
        ]
        let parameters: Parameters = [
            "model": "gpt-3.5-turbo", 
            "messages": messages,
        ]

        NetworkManager.shared.request(url: urlEndpoint, method: .post, parameters: parameters, headers: OpenAINetworkHelper.shared.headers()) { (result: Result<OpenAIResponse, Error>) in
            switch result {
            case .success(let response):
                let answer = response.choices.first?.message.content ?? ""
                completion(.success(answer))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
