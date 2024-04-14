//
//  JournalViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/11.
//

import UIKit
import SwiftUI

class JournalViewController: UIViewController {

    let textView = UITextView()
    let buttonContainerView = UIView()
    let imageButton = UIButton(type: .system)
    let templateButton = UIButton(type: .system)
    let suggestionsButton = UIButton(type: .system)
    var bottomConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    
    //MARK: - setup UI
    
    func setupUI() {
        
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        
        imageButton.setImage(UIImage(systemName: "photo"), for: .normal)
        templateButton.setImage(UIImage(systemName: "doc"), for: .normal)
        suggestionsButton.setImage(UIImage(systemName: "lightbulb"), for: .normal)
        
        //            imageButton.addTarget(self, action: #selector(didTapImageButton), for: .touchUpInside)
        //            templateButton.addTarget(self, action: #selector(didTapTemplateButton), for: .touchUpInside)
                    suggestionsButton.addTarget(self, action: #selector(didTapSuggestionsButton), for: .touchUpInside)
        
        // 設定 containerView
        let buttons = [imageButton, templateButton, suggestionsButton]
        for button in buttons {
            buttonContainerView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
        }
        buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonContainerView)
        
        setupConstraints()
    
    }
    
    func setupConstraints() {

        bottomConstraint = buttonContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        NSLayoutConstraint.activate([
                textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                textView.leftAnchor.constraint(equalTo: view.leftAnchor),
                textView.rightAnchor.constraint(equalTo: view.rightAnchor),
                textView.bottomAnchor.constraint(equalTo: buttonContainerView.topAnchor),

                buttonContainerView.leftAnchor.constraint(equalTo: view.leftAnchor),
                buttonContainerView.rightAnchor.constraint(equalTo: view.rightAnchor),
                buttonContainerView.heightAnchor.constraint(equalToConstant: 100),
                bottomConstraint!
        ])

        NSLayoutConstraint.activate([
            imageButton.leftAnchor.constraint(equalTo: buttonContainerView.leftAnchor),
            imageButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor),
            imageButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor),
            imageButton.widthAnchor.constraint(equalTo: buttonContainerView.widthAnchor, multiplier: 1/3)
        ])

        NSLayoutConstraint.activate([
            templateButton.leftAnchor.constraint(equalTo: imageButton.rightAnchor),
            templateButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor),
            templateButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor),
            templateButton.widthAnchor.constraint(equalTo: buttonContainerView.widthAnchor, multiplier: 1/3)
        ])

        NSLayoutConstraint.activate([
            suggestionsButton.leftAnchor.constraint(equalTo: templateButton.rightAnchor),
            suggestionsButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor),
            suggestionsButton.rightAnchor.constraint(equalTo: buttonContainerView.rightAnchor),
            suggestionsButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor),
            suggestionsButton.widthAnchor.constraint(equalTo: buttonContainerView.widthAnchor, multiplier: 1/3)
        ])
    }
    
    //MARK: - action
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            bottomConstraint?.constant = -keyboardHeight + view.safeAreaInsets.bottom
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        bottomConstraint?.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func didTapSuggestionsButton() {
        let journalData = JournalData()
        var contentView = ContentView()
        contentView.onCompletion = { [weak self] (title: String, image: UIImage?) in
            self?.textView.text = title
            if let image = journalData.selectedImage {
                self?.resizeImage(image, targetWidth: 100) { resizedImage in
                    if let resizedImage = resizedImage {
                        self?.insertImage(resizedImage)
                    }
                }
            }
            self?.dismiss(animated: true, completion: nil)
        }
        let hostingController = UIHostingController(rootView: contentView.environmentObject(journalData))
        present(hostingController, animated: true)
    }

    
    // 在 textView 插入圖片並 resize
    func insertImage(_ image: UIImage) {
            let textAttachment = NSTextAttachment()
            textAttachment.image = image
            
            let attributedString = NSAttributedString(attachment: textAttachment)
            
            let mutableAttributedString = NSMutableAttributedString(attributedString: textView.attributedText)
            mutableAttributedString.append(NSAttributedString(string: "\n"))
            mutableAttributedString.append(attributedString)
            
            textView.attributedText = mutableAttributedString
        }
    
    // 調整圖片為等比例縮放
    func resizeImage(_ image: UIImage, targetWidth: CGFloat, completion: @escaping (UIImage?) -> Void) {
        let size = image.size
        let scaleFactor = targetWidth / size.width
        let newHeight = size.height * scaleFactor
        let newSize = CGSize(width: targetWidth, height: newHeight)

        // 異步生成縮圖
        image.prepareThumbnail(of: newSize, completionHandler: { thumbnail in
            completion(thumbnail)
        })
    }
    
}
