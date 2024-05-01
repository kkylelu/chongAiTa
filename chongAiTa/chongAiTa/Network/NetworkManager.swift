//
//  NetworkManager.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/15.
//

import Foundation
import Alamofire

class NetworkManager {
    static let shared = NetworkManager()

    func request<T: Codable>(url: String, method: HTTPMethod, parameters: Parameters?, headers: HTTPHeaders, completion: @escaping ((Result<T, Error>) -> Void)) {
        print("Preparing to send request to \(url) with parameters: \(String(describing: parameters)) and headers: \(headers)")
        
        AF.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: T.self) { response in
                print("Response received")
                switch response.result {
                case .success(let data):
                    print("Request successful with data: \(data)")
                    completion(.success(data))
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    completion(.failure(error))
                }
            }
    }
}

