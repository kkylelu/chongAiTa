//
//  FakeDataGenerator.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/29.
//

import UIKit

class FakeDataGenerator {
    static func generateFakeJournals(count: Int) -> [Journal] {
        var journals: [Journal] = []
        for i in 0...count {
            let titleBodyPair = generateFakeTitleBodyPair(index: i)
            let journal = Journal(
                title: titleBodyPair.title,
                body: titleBodyPair.body,
                date: generateFakeDate(),
                images: [generateFakeImage(index: i)],
                place: generateFakePlace(),
                city: generateFakeCity(),
                imageUrls: []
            )
            journals.append(journal)
        }
        return journals
    }
    
    static func generateFakeTitleBodyPair(index: Int) -> (title: String, body: String) {
        let titleBodyPairs = [
            ("熊熊愛丟球", "這天和熊熊去公園，我們玩了丟接球，真希望我寫程式的速度可以跟他追球一樣快！"),
            ("綁頭巾就不怕看醫生了...吧？", "熊熊只要一進動物醫院就開始發抖，我只好用海賊王的頭巾讓他看不到周遭環境，看起來很像賣玉蘭花的婆婆。"),
            ("洗澎澎笑到瞇眼", "週末幫熊熊洗澡，牠開心到一沖澡就開始甩水，濺得我也滿身是水，真是讓我又好氣又好笑，但看到熊熊那麼開心，真的什麼煩惱都消失了！")
            
        ]
        
        if index >= 0 && index < titleBodyPairs.count {
            return titleBodyPairs[index]
        } else {
            return ("", "")
        }
    }
    
    static func generateFakeDate() -> Date {
        let randomDaysAgo = Int.random(in: 0...30)
        return Calendar.current.date(byAdding: .day, value: -randomDaysAgo, to: Date()) ?? Date()
    }
    
    static func generateFakePlace() -> String? {
        let places = ["台北 101", "陽明山國家公園", "淡水老街", "士林夜市", "西門町"]
        return places.randomElement()
    }
    
    static func generateFakeCity() -> String? {
        let cities = ["台北市", "新北市", "桃園市", "台中市", "高雄市"]
        return cities.randomElement()
    }
    
    static func generateFakeImage(index: Int) -> UIImage {
        let imageNames = ["dogInPark", "seeDoctorDog", "washDog"]
        let validIndex = index % imageNames.count
        let imageName = imageNames[validIndex]
        return UIImage(named: imageName) ?? UIImage()
    }
}


