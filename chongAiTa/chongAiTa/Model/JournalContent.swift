//
//  JournalContent.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/15.
//

import UIKit
public struct Journal {
    var id: UUID
    var title: String
    var body: String
    var date: Date
    var images: [UIImage]
    var place: String?
    var city: String?
    var imageUrls: [String]
    
    // 自動生成新的 UUID
    init(id: UUID = UUID(), title: String, body: String, date: Date, images: [UIImage], place: String?, city: String?, imageUrls: [String] = []) {
            self.id = id
            self.title = title
            self.body = body
            self.date = date
            self.images = images
            self.place = place
            self.city = city
            self.imageUrls = imageUrls
        }
}
