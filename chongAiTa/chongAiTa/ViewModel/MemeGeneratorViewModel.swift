//
//  MemeGeneratorViewModel.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/5/16.
//

import UIKit
import Lottie

class MemeGeneratorViewModel {
    
    var currentPetImage: UIImage?
    var selectedFilterType: FilterType?
    lazy var filterPreviews: [UIImage] = []
    
    // 增加 callback 方法，當資料更新時通知 VC
    var onImageUpdated: ((UIImage?) -> Void)?
    var onFilterPreviewsUpdated: (() -> Void)?
    
    init() {
        generateFilterPreviews()
    }
    
    // 產生所有濾鏡效果的預覽圖片給 VC
    private func generateFilterPreviews() {
        guard let originalImage = currentPetImage else { return }
        filterPreviews = FilterType.allCases.map { filterType in
            return applyFilter(to: originalImage, filterType: filterType)
        }
        onFilterPreviewsUpdated?()
    }
    
    // 套用濾鏡的邏輯
    func applyFilter(to image: UIImage, filterType: FilterType) -> UIImage {
        let context = CIContext(options: nil)
        if filterType == .none {
            return image
        }
        if let filter = CIFilter(name: filterType.filterName) {
            // 把濾鏡套用到單張圖片上
            filter.setValue(CIImage(image: image), forKey: kCIInputImageKey)
            // 提供套了濾鏡的新圖片
            if let outputImage = filter.outputImage,
               let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return image
    }
    
    func updateImage(_ image: UIImage) {
        self.currentPetImage = image
        onImageUpdated?(image)
        generateFilterPreviews()
    }
    
    func saveMeme(from view: UIView) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        return renderer.image { context in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
}
