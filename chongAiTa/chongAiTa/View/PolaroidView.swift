//
//  PolaroidView.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/5/10.
//

import UIKit

class PolaroidView: UIView {
    
    let imageFromJournalView: UIImageView
    let polaroidMaskView: UIView
    
    override init(frame: CGRect) {
        imageFromJournalView = UIImageView(frame: frame)
        polaroidMaskView = UIView(frame: frame)
        
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        imageFromJournalView.contentMode = .scaleAspectFill
        imageFromJournalView.clipsToBounds = true
        addSubview(imageFromJournalView)
        
                if let image = UIImage(named: "dogInPark") {
                    imageFromJournalView.image = image
                } else {
                    print("讀取照片失敗")
                }
        
        polaroidMaskView.backgroundColor = UIColor.white
        polaroidMaskView.alpha = 0.8
        addSubview(polaroidMaskView)
        
        backgroundColor = UIColor(red: 240/255, green: 234/255, blue: 214/255, alpha: 1.0)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 5, height: 5)
        layer.shadowRadius = 5
        layer.cornerRadius = 10
    }
    
    func configureWithImage(_ image: UIImage) {
        imageFromJournalView.image = image
    }
    
    func revealPhoto() {
        UIView.animate(withDuration: 2.0) {
            self.polaroidMaskView.alpha = 0.0
        }
    }
}
