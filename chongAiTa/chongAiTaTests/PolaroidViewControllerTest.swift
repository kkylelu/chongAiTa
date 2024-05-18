//
//  PolaroidViewControllerTest.swift
//  chongAiTaTests
//
//  Created by Kyle Lu on 2024/5/18.
//

import XCTest
import Kingfisher
@testable import chongAiTa

final class PolaroidViewControllerTest: XCTestCase {
    
    var sut: PolaroidViewController!
    var imageView: UIImageView!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = PolaroidViewController()
        sut.viewDidLoad()
        imageView = UIImageView()
        
    }
    
    override func tearDownWithError() throws {
        sut = nil
        imageView = nil
        try super.tearDownWithError()
        
    }
    
    func testSetupPolaroidImageWithEmptyJournalsArrayShowNoImage() {
        // Given
        sut.journalsArray = []
        
        // When
        sut.setupPolaroidImage()
        
        // Then
        XCTAssertNil(sut.imageView.image, "如果沒有任何日記，則無法顯示拍立得照片")
    }

    
    func testSetupPolaroidImageFailure() throws {
        // 準備 mock data
        let mockJournal = Journal(
            id: UUID(),
            title: "Test Title",
            body: "Test Body",
            date: Date(),
            images: [],
            place: nil,
            city: nil,
            imageUrls: ["https://example.com/invalid.jpg"]
        )
        sut.journalsArray = [mockJournal]
        
        sut.setupPolaroidImage()
        
        // 驗證 imageView 是否設定了圖片
        XCTAssertNil(sut.imageView.image, "照片的 URL 無效")
    }
}
