//
//  FilterCell.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/5/12.
//

import UIKit

class FilterCell: UICollectionViewCell {
    
    let overlayImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(overlayImageView)
        
        NSLayoutConstraint.activate([
            overlayImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            overlayImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            overlayImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            overlayImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


