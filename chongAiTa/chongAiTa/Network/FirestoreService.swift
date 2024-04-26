//
//  FirestoreService.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/26.
//

import Foundation
import FirebaseFirestore
import Alamofire

enum FirestoreError: Error {
    case noData
    case decodingError
}

class FirestoreService {
    static let shared = FirestoreService()
    
    let db = Firestore.firestore()
    
    func uploadFAQCategory(_ faqCategory: FAQCategory, completion: @escaping (Result<Void, Error>) -> Void) {
        let faqCategoryRef = db.collection("faqs").document(faqCategory.id ?? "")
        
        faqCategoryRef.setData(["id": faqCategory.id ?? ""]) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let uploadEntries = { (collectionName: String, entries: [FAQEntry], completionHandler: @escaping (Error?) -> Void) in
                let entriesCollection = faqCategoryRef.collection(collectionName)
                let dispatchGroup = DispatchGroup()
                
                for entry in entries {
                    dispatchGroup.enter()
                    let entryData = ["question": entry.question, "answer": entry.answer]
                    entriesCollection.addDocument(data: entryData) { error in
                        if let error = error {
                            completionHandler(error)
                        }
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    completionHandler(nil)
                }
            }
            
            let dispatchGroup = DispatchGroup()
            
            dispatchGroup.enter()
            uploadEntries("health", faqCategory.health) { error in
                if let error = error {
                    completion(.failure(error))
                }
                dispatchGroup.leave()
            }
            
            dispatchGroup.enter()
            uploadEntries("nutrition", faqCategory.nutrition) { error in
                if let error = error {
                    completion(.failure(error))
                }
                dispatchGroup.leave()
            }
            
            dispatchGroup.enter()
            uploadEntries("care", faqCategory.care) { error in
                if let error = error {
                    completion(.failure(error))
                }
                dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(.success(()))
            }
        }
    }

    
    func fetchFAQCategory(completion: @escaping (Result<FAQCategory, Error>) -> Void) {
        db.collection("faqs").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                completion(.failure(FirestoreError.noData))
                return
            }
            
            var healthEntries: [FAQEntry] = []
            var nutritionEntries: [FAQEntry] = []
            var careEntries: [FAQEntry] = []
            
            for document in documents {
                let faqCategoryID = document.documentID
                
                // 獲取 health 分類的文件
                self.db.collection("faqs").document(faqCategoryID).collection("health").getDocuments { snapshot, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    if let entries = snapshot?.documents.compactMap({ try? $0.data(as: FAQEntry.self) }) {
                        healthEntries.append(contentsOf: entries)
                    }
                    
                    // 獲取 nutrition 分類的文件
                    self.db.collection("faqs").document(faqCategoryID).collection("nutrition").getDocuments { snapshot, error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        
                        if let entries = snapshot?.documents.compactMap({ try? $0.data(as: FAQEntry.self) }) {
                            nutritionEntries.append(contentsOf: entries)
                        }
                        
                        // 獲取 care 分類的文件
                        self.db.collection("faqs").document(faqCategoryID).collection("care").getDocuments { snapshot, error in
                            if let error = error {
                                completion(.failure(error))
                                return
                            }
                            
                            if let entries = snapshot?.documents.compactMap({ try? $0.data(as: FAQEntry.self) }) {
                                careEntries.append(contentsOf: entries)
                            }
                            
                            let faqCategory = FAQCategory(id: faqCategoryID, health: healthEntries, nutrition: nutritionEntries, care: careEntries)
                            completion(.success(faqCategory))
                        }
                    }
                }
            }
        }
    }
    
    func performRequest<T: Codable>(url: String, method: HTTPMethod, parameters: Parameters?, headers: HTTPHeaders, completion: @escaping ((Result<T, Error>) -> Void)) {
        NetworkManager.shared.request(url: url, method: method, parameters: parameters, headers: headers, completion: completion)
    }
}
