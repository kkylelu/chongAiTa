//
//  JournalViewControllerTest.swift
//  chongAiTaTests
//
//  Created by Kyle Lu on 2024/5/18.
//

import XCTest
@testable import chongAiTa

final class JournalViewControllerTest: XCTestCase {
    
    var sut: JournalViewController!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = JournalViewController()
        
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    // 測試日記圖片是否為空值以及寬高要符合預期
    func testResizeImage() {
        // given
        guard let originalImage = UIImage(named: "Placeholder picture") else {
            XCTFail("找不到測試圖片")
            return
        }
        let targetWidth: CGFloat = 100.0
        let expectation = self.expectation(description: "圖片縮放完成")
        
        // when
        // 傳送測試圖片和目標寬度
        sut.resizeImage(originalImage, targetWidth: targetWidth) { resizedImage in
            // then
            // 第一次檢查：快速確認 resizedImage 是否為 nil
            XCTAssertNotNil(resizedImage, "縮放後的圖片不能是空值")
            
            // 第二次檢查：用 XCTUnwrap 解包 optional
            do {
                let resizedImage = try XCTUnwrap(resizedImage, "縮放後的圖片不能是空值")
                XCTAssertEqual(resizedImage.size.width, targetWidth, accuracy: 0.1, "縮放後圖片的寬度應該是 \(targetWidth)")
                let expectedHeight = originalImage.size.height * (targetWidth / originalImage.size.width)
                XCTAssertEqual(resizedImage.size.height, expectedHeight, accuracy: 0.1, "縮放後圖片的高度應該是 \(expectedHeight)")
                expectation.fulfill()
            } catch {
                XCTFail("解包縮放後圖片失敗")
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
}
