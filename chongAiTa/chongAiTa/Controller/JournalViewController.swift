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
    let titleLabel = UILabel()
    let buttonContainerView = UIView()
    let imageButton = UIButton(type: .system)
    let templateButton = UIButton(type: .system)
    let suggestionsButton = UIButton(type: .system)
    var bottomConstraint: NSLayoutConstraint?
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    var activeImageProcessingCount = 0
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }

    
    //MARK: - setup UI
    
    func setupUI() {
        
        let grayColor = UIColor.systemGray

        titleLabel.font = UIFont(name: "HelveticaNeue", size: 30)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        textView.font = UIFont(name: "HelveticaNeue", size: 24)
        textView.isEditable = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        

        imageButton.setImage(UIImage(systemName: "photo")?.withTintColor(grayColor, renderingMode: .alwaysOriginal), for: .normal)
        imageButton.setTitle("照片", for: .normal)
        imageButton.tintColor = grayColor
        imageButton.titleLabel?.textAlignment = .center

//        templateButton.setImage(UIImage(systemName: "doc")?.withTintColor(grayColor, renderingMode: .alwaysOriginal), for: .normal)
//        templateButton.setTitle("範本", for: .normal)
//        templateButton.tintColor = grayColor
//        templateButton.titleLabel?.textAlignment = .center

        suggestionsButton.setImage(UIImage(systemName: "lightbulb")?.withTintColor(grayColor, renderingMode: .alwaysOriginal), for: .normal)
        suggestionsButton.setTitle("建議", for: .normal)
        suggestionsButton.tintColor = grayColor
        suggestionsButton.titleLabel?.textAlignment = .center

        
        
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
        
        buttonContainerView.layer.cornerRadius = 10
        buttonContainerView.layer.borderWidth = 1
        buttonContainerView.layer.borderColor = UIColor.lightGray.cgColor
        
        setupConstraints()
        
    }
    
    func setupConstraints() {
        
        bottomConstraint = buttonContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        guard let bottom = bottomConstraint else {
                print("Failed to init bottomConstraint")
                return
            }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            textView.bottomAnchor.constraint(equalTo: buttonContainerView.topAnchor),
            
            buttonContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            buttonContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            buttonContainerView.heightAnchor.constraint(equalToConstant: 50),
            bottom
           
        ])
        
        NSLayoutConstraint.activate([
            imageButton.leftAnchor.constraint(equalTo: buttonContainerView.leftAnchor),
            imageButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor),
            imageButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor),
            imageButton.widthAnchor.constraint(equalTo: buttonContainerView.widthAnchor, multiplier: 1/2)
        ])
        
//        NSLayoutConstraint.activate([
//            templateButton.leftAnchor.constraint(equalTo: imageButton.rightAnchor),
//            templateButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor),
//            templateButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor),
//            templateButton.widthAnchor.constraint(equalTo: buttonContainerView.widthAnchor, multiplier: 1/3)
//        ])
        
        NSLayoutConstraint.activate([
            suggestionsButton.leftAnchor.constraint(equalTo: templateButton.rightAnchor),
            suggestionsButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor),
            suggestionsButton.rightAnchor.constraint(equalTo: buttonContainerView.rightAnchor),
            suggestionsButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor),
            suggestionsButton.widthAnchor.constraint(equalTo: buttonContainerView.widthAnchor, multiplier: 1/2)
        ])
    }
    
    //MARK: - action
    
    // 讓鍵盤把 bottomConstraint 往上推
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
        contentView.onCompletion = { [weak self] (title: String, images: [UIImage]) in
            self?.titleLabel.text = title
            self?.processImages(images)
            self?.dismiss(animated: true, completion: nil)
        }
        let hostingController = UIHostingController(rootView: contentView.environmentObject(journalData))
        present(hostingController, animated: true)
    }
    
    
    func processImages(_ images: [UIImage]) {
        for image in images {
            showActivityIndicator()
            resizeImage(image, targetWidth: 300) { [weak self] resizedImage in
                DispatchQueue.main.async {
                    if let resizedImage = resizedImage {
                        self?.insertImage(resizedImage)
                    }
                    self?.hideActivityIndicator()
                }
            }
        }
    }
    
    
    // 在 textView 插入圖片並 resize
    func insertImage(_ image: UIImage) {
        DispatchQueue.main.async {
            let textAttachment = NSTextAttachment()
            textAttachment.image = image
            
            let attributedString = NSAttributedString(attachment: textAttachment)
            
            let mutableAttributedString = NSMutableAttributedString(attributedString: self.textView.attributedText)
            mutableAttributedString.append(NSAttributedString(string: "\n"))
            mutableAttributedString.append(attributedString)
            
            self.textView.attributedText = mutableAttributedString
        }
    }
    
    func resizeImage(_ image: UIImage, targetWidth: CGFloat, completion: @escaping (UIImage?) -> Void) {
        let size = image.size
        let scaleFactor = targetWidth / size.width
        let newHeight = size.height * scaleFactor
        let newSize = CGSize(width: targetWidth, height: newHeight)
        
        image.prepareThumbnail(of: newSize, completionHandler: { [weak self] thumbnail in
            guard let strongSelf = self else { return }
            completion(thumbnail)
        })
    }
    
    func showActivityIndicator() {
        DispatchQueue.main.async {
            if self.activeImageProcessingCount == 0 {
                self.activityIndicator.startAnimating()
            }
            self.activeImageProcessingCount += 1
        }
    }
    
    func hideActivityIndicator() {
        DispatchQueue.main.async {
            self.activeImageProcessingCount -= 1
            if self.activeImageProcessingCount == 0 {
                self.activityIndicator.stopAnimating()
            }
        }
    }
}
