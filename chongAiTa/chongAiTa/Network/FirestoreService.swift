//
//  FirestoreService.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/26.
//

import Foundation
import FirebaseFirestore
import Alamofire
import FirebaseStorage

enum FirestoreError: Error {
    case noData
    case decodingError
}

class FirestoreService {
    static let shared = FirestoreService()
    
    let db = Firestore.firestore()
    
    // MARK: - Upload and Fetch FAQs
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
    
    // MARK: - Upload and Fetch Events

    func uploadEvent(userId: String, event: CalendarEvents, completion: @escaping (Result<Void, Error>) -> Void) {
        let eventRef = db.collection("user").document(userId).collection("events").document(event.id.uuidString) 
        
        let eventData: [String: Any] = [
            "id": event.id.uuidString,
            "title": event.title,
            "date": event.date,
            "activity": [
                "category": event.activity.category.rawValue,
                "date": event.activity.date
            ],
            "content": event.content ?? "",
            "cost": event.cost ?? 0.0,
            "recurrence": event.recurrence?.rawValue ?? ""
        ]
        print("Uploading event to Firestore: \(event)")
        
        eventRef.setData(eventData) { error in
            if let error = error {
                print("Error uploading event to Firestore: \(error)")
                completion(.failure(error))
            } else {
                print("Event successfully uploaded to Firestore: \(event)")
                completion(.success(())) 
            }
        }
    }
    
    
    func fetchEvents(userId: String, from startDate: Date, to endDate: Date, completion: @escaping (Result<[CalendarEvents], Error>) -> Void) {
        let userEventsCollection = db.collection("user").document(userId).collection("events")
        let query = userEventsCollection
            .whereField("date", isGreaterThanOrEqualTo: startDate)
            .whereField("date", isLessThan: endDate)
        
        query.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else if let documents = snapshot?.documents {
                let events = documents.compactMap { document -> CalendarEvents? in
                    let data = document.data()
                    guard let id = data["id"] as? String,
                          let title = data["title"] as? String,
                          let date = data["date"] as? Timestamp,
                          let activityData = data["activity"] as? [String: Any],
                          let categoryRawValue = activityData["category"] as? Int,
                          let category = ActivityCategory(rawValue: categoryRawValue),
                          let activityDate = activityData["date"] as? Timestamp else {
                        return nil
                    }
                    
                    let content = data["content"] as? String
                    let cost = data["cost"] as? Double
                    let recurrenceRawValue = data["recurrence"] as? String
                    let recurrence = Recurrence(rawValue: recurrenceRawValue ?? "")
                    
                    let activity = DefaultActivity(category: category, date: activityDate.dateValue())
                    
                    return CalendarEvents(id: UUID(uuidString: id)!, title: title, date: date.dateValue(), activity: activity, content: content, cost: cost, recurrence: recurrence)
                }
                completion(.success(events))
            } else {
                completion(.success([]))
            }
        }
    }
    
    func deleteEvent(userId: String, event: CalendarEvents, completion: @escaping (Result<Void, Error>) -> Void) {
        let eventRef = db.collection("user").document(userId).collection("events").document(event.id.uuidString)
        eventRef.delete() { error in
            if let error = error {
                print("Error deleting event from Firestore: \(error)")
                completion(.failure(error))
            } else {
                print("Event successfully deleted from Firestore")
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Upload and Fetch Journals
    
    func uploadJournal(userId: String, journal: Journal, completion: @escaping (Result<Void, Error>) -> Void) {
        let journalRef = db.collection("user").document(userId).collection("journals").document(journal.id.uuidString)
        
        let journalData: [String: Any] = [
            "id": journal.id.uuidString,
            "title": journal.title,
            "body": journal.body,
            "date": journal.date,
            "imageUrls": journal.imageUrls
        ]
        
        journalRef.setData(journalData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func fetchJournals(userId: String, completion: @escaping (Result<[Journal], Error>) -> Void) {
        let journalsCollection = db.collection("user").document(userId).collection("journals")
        journalsCollection.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else if let documents = snapshot?.documents {
                let journals = documents.compactMap { document -> Journal? in
                    let data = document.data()
                    guard let id = data["id"] as? String,
                          let title = data["title"] as? String,
                          let body = data["body"] as? String,
                          let date = data["date"] as? Timestamp,
                          let imageUrls = data["imageUrls"] as? [String] else {
                        return nil
                    }
                    
                    return Journal(id: UUID(uuidString: id)!, title: title, body: body, date: date.dateValue(), images: [], place: nil, city: nil, imageUrls: imageUrls)
                }
                completion(.success(journals))
            } else {
                completion(.success([]))
            }
        }
    }
    
    func deleteJournal(userId: String, journal: Journal, completion: @escaping (Result<Void, Error>) -> Void) {
        let journalRef = db.collection("user").document(userId).collection("journals").document(journal.id.uuidString)
        
        // 刪除 Firestore 資料
        journalRef.delete { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // 刪除與日記相關的所有圖片
            let storageRef = Storage.storage().reference()
            let deleteGroup = DispatchGroup()
            
            for imageUrl in journal.imageUrls {
                deleteGroup.enter()
                let imageRef = storageRef.child(imageUrl)
                imageRef.delete { error in
                    if let error = error {
                        print("Error deleting image: \(error.localizedDescription)")
                    }
                    deleteGroup.leave()
                }
            }
            
            deleteGroup.notify(queue: .main) {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Upload and Fetch Pet
    func uploadPet(userId: String, pet: Pet, completion: @escaping (Error?) -> Void) {
        let petRef = db.collection("user").document(userId).collection("pets").document(pet.id.uuidString)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let birthdayString = pet.birthday.map { dateFormatter.string(from: $0) } ?? ""
            let joinDateString = pet.joinDate.map { dateFormatter.string(from: $0) } ?? ""
            
            let petData: [String: Any] = [
                "id": pet.id.uuidString,
                "imageUrl": pet.imageUrl,
                "name": pet.name,
                "gender": pet.gender.rawValue,
                "type": pet.type.rawValue,
                "breed": pet.breed ?? "",
                "birthday": birthdayString,
                "joinDate": joinDateString,
                "weight": pet.weight ?? 0,
                "isNeutered": pet.isNeutered
            ]
            
            petRef.setData(petData) { error in
                if let error = error {
                    print("上傳寵物資料失敗: \(error.localizedDescription)")
                } else {
                    print("寵物資料成功上傳至雲端。")
                }
                completion(error)
            }
        }

    func fetchPet(userId: String, petName: String, completion: @escaping (Result<Pet, Error>) -> Void) {
        let collectionRef = db.collection("user").document(userId).collection("pets")
        let query = collectionRef.whereField("name", isEqualTo: petName)
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("獲取寵物資料失敗: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                        let error = NSError(domain: "PetNotFoundError", code: -1, userInfo: nil)
                        print("找不到寵物資料: \(error.localizedDescription)")
                        completion(.failure(error))
                        return
                    }
            
            if let document = documents.first {
                let data = document.data()
                guard let id = UUID(uuidString: data["id"] as? String ?? ""),
                      let name = data["name"] as? String,
                      let imageUrl = data["imageUrl"] as? [String],
                      let genderRaw = data["gender"] as? String,
                      let gender = Pet.Gender(rawValue: genderRaw),
                      let typeRaw = data["type"] as? Int,
                      let type = Pet.PetType(rawValue: typeRaw),
                      let birthdayString = data["birthday"] as? String,
                      let joinDateString = data["joinDate"] as? String else {
                    completion(.failure(NSError(domain: "DataFormatError", code: 1001, userInfo: nil)))
                    let error = NSError(domain: "DataFormatError", code: 1001, userInfo: nil)
                                    print("寵物資料格式錯誤: \(error.localizedDescription)")
                                    completion(.failure(error))
                                    return
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let birthday = dateFormatter.date(from: birthdayString)
                let joinDate = dateFormatter.date(from: joinDateString)
                let breed = data["breed"] as? String
                let weight = data["weight"] as? Double
                let isNeutered = data["isNeutered"] as? Bool ?? false
                
                let pet = Pet(id: id, image: imageUrl.isEmpty ? "ShibaInuIcon" : nil, imageUrl: imageUrl, name: name, gender: gender, type: type, breed: breed, birthday: birthday, joinDate: joinDate, weight: weight, isNeutered: isNeutered)
                completion(.success(pet))
            } else {
                let error = NSError(domain: "PetNotFoundError", code: -1, userInfo: nil)
                            print("找不到寵物資料: \(error.localizedDescription)")
                completion(.failure(NSError(domain: "PetNotFoundError", code: -1, userInfo: nil)))
            }
        }
    }


    // MARK: - PerformRequest
    func performRequest<T: Codable>(url: String, method: HTTPMethod, parameters: Parameters?, headers: HTTPHeaders, completion: @escaping ((Result<T, Error>) -> Void)) {
        NetworkManager.shared.request(url: url, method: method, parameters: parameters, headers: headers, completion: completion)
    }
    
}
