//
//  MessageBubbleTableViewCell.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/18.
//

import UIKit

class MessageBubbleTableViewCell: UITableViewCell {
    let messageLabel = UILabel()
    let bubbleBackgroundView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(bubbleBackgroundView)
        addSubview(messageLabel)
        
        bubbleBackgroundView.backgroundColor = .lightGray
        bubbleBackgroundView.layer.cornerRadius = 12
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        
        NSLayoutConstraint.activate([
            bubbleBackgroundView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -8),
            bubbleBackgroundView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8),
            bubbleBackgroundView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -16),
            bubbleBackgroundView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 16)
        ])
        
    }
    
    
    func configure(with message: String, isFromCurrentUser: Bool) {
        messageLabel.text = message
        messageLabel.textColor = isFromCurrentUser ? .white : .black
        bubbleBackgroundView.backgroundColor = isFromCurrentUser ? .B1 : .systemGray6

        NSLayoutConstraint.deactivate(messageLabel.constraints)

        let topConstraint = messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16)
        let bottomConstraint = messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        NSLayoutConstraint.activate([topConstraint, bottomConstraint])

        if isFromCurrentUser {
            // 來自使用者的訊息
            let trailingConstraint = messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -35)
            NSLayoutConstraint.activate([trailingConstraint])

            let leadingConstraint = messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 100)
            NSLayoutConstraint.activate([leadingConstraint])
            
        } else {
            // 來自 AI 的訊息
            let leadingConstraint = messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 35)
            NSLayoutConstraint.activate([leadingConstraint])

            let trailingConstraint = messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -100)
            NSLayoutConstraint.activate([trailingConstraint])
        }
    }

}
