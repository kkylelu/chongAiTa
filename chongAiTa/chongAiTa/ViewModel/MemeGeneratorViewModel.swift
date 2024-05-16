//
//  MemeGeneratorViewModel.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/5/16.
//

import UIKit
import Lottie

class MemeGeneratorViewModel {
    
    var petImage: UIImage?
    var filterPreviews: [UIImage] = []
    var selectedFilterType: FilterType?
    
    // 增加 callback 方法，當資料更新時通知 VC
    var onImageUpdated: ((UIImage?) -> Void)?
    var onFilterPreviewsUpdated: (() -> Void)?
    
    init() {
        generateFilterPreviews()
    }
    
    // 把預覽濾鏡從 VC 移到 VM
    func generateFilterPreviews() {
        guard let originalImage = petImage else { return }
        filterPreviews = FilterType.allCases.map { filterType in
            return applyFilter(to: originalImage, filterType: filterType)
        }
        onFilterPreviewsUpdated?()
    }

    // 把套用濾鏡從 VC 移到 VM
    func applyFilter(to image: UIImage, filterType: FilterType) -> UIImage {
            let context = CIContext(options: nil)
            if filterType == .none {
                return image
            }
            if let filter = CIFilter(name: filterType.filterName) {
                filter.setValue(CIImage(image: image), forKey: kCIInputImageKey)
                if let outputImage = filter.outputImage,
                   let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                    return UIImage(cgImage: cgImage)
                }
            }
            return image
        }
    
    func updateImage(_ image: UIImage) {
        self.petImage = image
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
