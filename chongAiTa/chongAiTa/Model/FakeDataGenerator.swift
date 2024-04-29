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
                    images: generateFakeImages(),
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
                ("第一次做狗餅乾就放棄", "這天我決定挑戰做狗餅乾給熊熊，誰知道我的廚藝跟附近寵物美容一樣，都是三腳貓水準。熊熊吃了一口，露出一副「你這是在搞笑吧？」的表情。最後，我還是乖乖拿出平時買的零食來安撫牠的味蕾。關於要吃的食物，我們還是留給專業的來好了。"),
                ("不要再追了，那只是塑膠袋", "晚上帶熊熊去散步，街上的燈光閃爍，熊熊每次看到反光的東西就激動得不行。今天牠竟然試圖去追一個閃亮的塑膠袋，差點把我也拖進草叢。回家路上，熊熊靠在我腳邊，我低頭看著牠滿足的小臉，心裡想著，這就是幸福吧！寵物的陪伴，總是讓人感到無比的溫馨。"),
                ("熊熊大戰松鼠", "今天我和熊熊去公園，它看到松鼠就像見到宿敵一樣，眼神銳利得可以拿來切披薩。我們玩了丟球，熊熊追球的速度比我更新App還快，根本沒空理我。這樣的日子超讚，希望每天都能這麼陽光燦爛。")
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
    
    static func generateFakeImages() -> [UIImage] {
        let imageNames = ["mydog", "mydog", "mydog"]
        let randomImageName = imageNames.randomElement() ?? ""
        guard let image = UIImage(named: randomImageName) else {
            return []
        }
        return [image]
    }
}

