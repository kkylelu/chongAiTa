//
//  JournalViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/11.
//

import UIKit
import SwiftUI
import JournalingSuggestions
import FirebaseFirestore

class JournalViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    let titleTextView = UITextView()
    let bodyTextView = UITextView()
    let buttonContainerView = UIView()
    let imageButton = UIButton(type: .system)
    let templateButton = UIButton(type: .system)
    let suggestionsButton = UIButton(type: .system)
    var bottomConstraint: NSLayoutConstraint?
    let imagePicker = UIImagePickerController()
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    var activeImageProcessingCount = 0
    
    var selectedDate: Date?
    var selectedImages = [UIImage]()
    var selectedLocation: String?
    var selectedPlace: String?
    var selectedCity: String?
    
    var imagesReadyToSave = false
    
    let titlePlaceholder = "輸入標題"
    let bodyPlaceholder = "輸入內容"
    
    var journal: Journal?
        
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        selectedDate = Date()
        
        if let journal = journal {
            updateUI(with: journal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            if journal == nil {
                titleTextView.becomeFirstResponder()
            } else {
                bodyTextView.becomeFirstResponder()
            }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        titleTextView.resignFirstResponder()
            bodyTextView.resignFirstResponder()
    }
    
    
    //MARK: - Setup UI
    
    func setupUI() {
        
        titleTextView.delegate = self
        bodyTextView.delegate = self
        
        view.backgroundColor = .white
        
        // Navigationbar
        let datePicker = UIDatePicker()
        datePicker.date = Date()
        datePicker.datePickerMode = .date
        datePicker.backgroundColor = UIColor.clear
        datePicker.tintColor = UIColor.white
        datePicker.setValue(UIColor.white, forKey: "textColor")
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        let leftBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        let rightBarButtonItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(doneButtonTapped))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.B1
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationController?.navigationBar.tintColor = UIColor.white
        
        // TextView
        let grayColor = UIColor.systemGray
        
        titleTextView.text = titlePlaceholder
        titleTextView.textColor = .lightGray
        
        titleTextView.font = UIFont.boldSystemFont(ofSize: 30)
        titleTextView.isEditable = true
        titleTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleTextView)
        
        bodyTextView.text = bodyPlaceholder
        bodyTextView.textColor = .lightGray
        
        bodyTextView.font = UIFont.systemFont(ofSize: 24)
        bodyTextView.isEditable = true
        bodyTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bodyTextView)
        
        imageButton.setImage(UIImage(systemName: "photo")?.withTintColor(grayColor, renderingMode: .alwaysOriginal), for: .normal)
        imageButton.setTitle("照片", for: .normal)
        imageButton.tintColor = grayColor
        imageButton.titleLabel?.textAlignment = .center
        
        suggestionsButton.setImage(UIImage(systemName: "wand.and.stars")?.withTintColor(grayColor, renderingMode: .alwaysOriginal), for: .normal)
        suggestionsButton.setTitle("靈感", for: .normal)
        suggestionsButton.tintColor = grayColor
        suggestionsButton.titleLabel?.textAlignment = .center
        
        imageButton.addTarget(self, action: #selector(didTapImageButton), for: .touchUpInside)
        //            templateButton.addTarget(self, action: #selector(didTapTemplateButton), for: .touchUpInside)
        suggestionsButton.addTarget(self, action: #selector(didTapSuggestionsButton), for: .touchUpInside)
        
        // containerView
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
            
            titleTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleTextView.heightAnchor.constraint(equalToConstant: 80),
            
            bodyTextView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 10),
            bodyTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bodyTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bodyTextView.bottomAnchor.constraint(equalTo: buttonContainerView.topAnchor, constant: -20),
            
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
        
        NSLayoutConstraint.activate([
            suggestionsButton.leftAnchor.constraint(equalTo: templateButton.rightAnchor),
            suggestionsButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor),
            suggestionsButton.rightAnchor.constraint(equalTo: buttonContainerView.rightAnchor),
            suggestionsButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor),
            suggestionsButton.widthAnchor.constraint(equalTo: buttonContainerView.widthAnchor, multiplier: 1/2)
        ])
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView === titleTextView && textView.text == titlePlaceholder {
            textView.text = nil
            textView.textColor = .black
        } else if textView === bodyTextView && textView.text == bodyPlaceholder {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView === titleTextView && textView.text.isEmpty {
            textView.text = titlePlaceholder
            textView.textColor = .lightGray
        } else if textView === bodyTextView && textView.text.isEmpty {
            textView.text = bodyPlaceholder
            textView.textColor = .lightGray
        }
    }
    
    
    // MARK: - UpdateUI
    func updateUI(with journal: Journal) {
        titleTextView.text = journal.title
        bodyTextView.text = journal.body
        
        // 判斷是否需要設定非 placeholder 文本顏色
        titleTextView.textColor = journal.title.isEmpty ? .lightGray : .black
        bodyTextView.textColor = journal.body.isEmpty ? .lightGray : .black

        // 如果日記內容與 placeholder 相同，則仍顯示為 lightGray
        if titleTextView.text == titlePlaceholder {
            titleTextView.textColor = .lightGray
        }
        if bodyTextView.text == bodyPlaceholder {
            bodyTextView.textColor = .lightGray
        }

        let attributedString = NSMutableAttributedString(string: journal.body)
        let textViewFont = bodyTextView.font ?? UIFont.systemFont(ofSize: 24)
        let range = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttribute(.font, value: textViewFont, range: range)

        bodyTextView.attributedText = attributedString
        selectedImages = journal.images
        insertImagesIntoTextView()
    }

    
    func updateTextViews(title: String, body: String) {
        let titleFont = UIFont.boldSystemFont(ofSize: 30)
        let bodyFont = UIFont.systemFont(ofSize: 24)
        
        titleTextView.font = titleFont
        titleTextView.text = title
        
        bodyTextView.font = bodyFont
        bodyTextView.text = body
    }
    
    
    //MARK: - Action
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            view.endEditing(true)
        }
    
    @objc func dateChanged(_ datePicker: UIDatePicker) {
        selectedDate = datePicker.date
    }
    
    @objc func doneButtonTapped() {
        if let title = titleTextView.text, let body = bodyTextView.text, let date = selectedDate {
            let newJournal = Journal(id: journal?.id ?? UUID(), title: title, body: body, date: date, images: selectedImages, place: selectedPlace, city: selectedCity)
            
            NotificationCenter.default.post(name: .newJournalEntrySaved, object: nil, userInfo: ["journal": newJournal])
            navigationController?.popViewController(animated: true)
        } else {
            print("Error: Missing information")
        }
    }
    
    // 讓鍵盤把 bottomConstraint 往上推
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            
            DispatchQueue.main.async {
                let bottomSafeAreaInset = self.view.safeAreaInsets.bottom
                self.bottomConstraint?.constant = -(keyboardHeight - bottomSafeAreaInset)
                
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
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
        let journalData = JournalPickerData()
        var contentView = ContentView()
        contentView.onCompletion = { [weak self] (title: String, images: [UIImage], place: String?, city: String?) in
            DispatchQueue.main.async {
                self?.updateTextViews(title: title, body: self?.bodyTextView.text ?? "")
                self?.processImages(images)
                self?.selectedPlace = place
                self?.selectedCity = city
                self?.dismiss(animated: true, completion: nil)
            }
        }

        let hostingController = UIHostingController(rootView: contentView.environmentObject(journalData))
        present(hostingController, animated: true)
    }

    
    @objc func didTapImageButton() {
        let alertController = UIAlertController(title: "選擇圖片來源", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "相簿", style: .default, handler: { [weak self] _ in
            self?.imagePicker.sourceType = .photoLibrary
            self?.present(self!.imagePicker, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "相機", style: .default, handler: { [weak self] _ in
            self?.imagePicker.sourceType = .camera
            self?.present(self!.imagePicker, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            let targetWidth = bodyTextView.bounds.width / 2
            resizeImage(selectedImage, targetWidth: targetWidth) { [weak self] resizedImage in
                DispatchQueue.main.async {
                    if let resizedImage = resizedImage {
                        self?.selectedImages.append(resizedImage)
                        self?.insertImage(resizedImage)
                        print("Image processed and added to the array. Total now: \(self?.selectedImages.count ?? 0)")
                        self?.imagesReadyToSave = true
                    }
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func processImages(_ images: [UIImage]) {
        var processedImagesCount = 0
        let totalImages = images.count
        for image in images {
            showActivityIndicator()
            resizeImage(image, targetWidth: bodyTextView.bounds.width / 2) { [weak self] resizedImage in
                DispatchQueue.main.async {
                    if let resizedImage = resizedImage {
                        self?.selectedImages.append(resizedImage)
                        processedImagesCount += 1
                        print("Processed \(processedImagesCount) of \(totalImages) images")
                    }
                    self?.hideActivityIndicator()
                    if processedImagesCount == totalImages {
                        print("All images processed.")
                        self?.imagesReadyToSave = true
                        // 在處理完所有圖片後，將圖片插入到 textView 中
                        self?.insertImagesIntoTextView()
                    }
                }
            }
        }
    }
    
    func insertImagesIntoTextView() {
        let attributedString = NSMutableAttributedString(attributedString: bodyTextView.attributedText)
        
        let textViewFont = bodyTextView.font ?? UIFont.systemFont(ofSize: 24)
        let textViewAttributes: [NSAttributedString.Key: Any] = [
            .font: textViewFont
        ]
        
        for image in selectedImages {
            let attachment = NSTextAttachment()
            attachment.image = image
            
            let attachmentString = NSAttributedString(attachment: attachment)
            
            if attributedString.length > 0 {
                attributedString.append(NSAttributedString(string: "\n", attributes: textViewAttributes))
            }
            
            attributedString.append(attachmentString)
            attributedString.append(NSAttributedString(string: "\n", attributes: textViewAttributes))
        }
        
        bodyTextView.attributedText = attributedString
    }
    
    // 在 textView 插入圖片並 resize
    func insertImage(_ image: UIImage) {
        DispatchQueue.main.async {
            let textAttachment = NSTextAttachment()
            textAttachment.image = image
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: self.bodyTextView.font!,
                .paragraphStyle: paragraphStyle
            ]
            
            let attributedStringWithImage = NSAttributedString(attachment: textAttachment)
            let imageString = NSMutableAttributedString(attributedString: attributedStringWithImage)
            imageString.addAttributes(attrs, range: NSRange(location: 0, length: imageString.length))
            
            let mutableAttributedString = NSMutableAttributedString(attributedString: self.bodyTextView.attributedText)
            
            mutableAttributedString.append(NSAttributedString(string: "\n", attributes: attrs))
            mutableAttributedString.append(imageString)
            mutableAttributedString.append(NSAttributedString(string: "\n", attributes: attrs))
            
            self.bodyTextView.attributedText = mutableAttributedString
            self.bodyTextView.becomeFirstResponder()
            
            let newPosition = self.bodyTextView.endOfDocument
            self.bodyTextView.selectedTextRange = self.bodyTextView.textRange(from: newPosition, to: newPosition)
        }
    }
    
    func resizeImage(_ image: UIImage, targetWidth: CGFloat, completion: @escaping (UIImage?) -> Void) {
        let size = image.size
        let scaleFactor = targetWidth / size.width
        let newHeight = size.height * scaleFactor
        let newSize = CGSize(width: targetWidth, height: newHeight)
        
        image.prepareThumbnail(of: newSize, completionHandler: { [weak self] thumbnail in
            print("Is main thread: \(Thread.isMainThread)")
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
