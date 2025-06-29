//
//  JournalViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/11.
//

import UIKit
import SwiftUI
import FirebaseFirestore
import Kingfisher
import FirebaseStorage
import FirebaseAuth

#if !targetEnvironment(simulator)
import JournalingSuggestions
#endif

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
    var selectedImageURLs = [String]()
    var selectedLocation: String?
    var selectedPlace: String?
    var selectedCity: String?
    
    var imagesReadyToSave = false
    
    let titlePlaceholder = "輸入標題"
    let bodyPlaceholder = "輸入內容"
    
    var journal: Journal?
    var isNewDiary: Bool = true
    
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isNewDiary = (journal == nil)
        
        setupUI()

        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        selectedDate = Date()
        
        if let journal = journal {
            updateUI(with: journal)
        } else {
            titleTextView.becomeFirstResponder()
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
        
        applyDynamicBackgroundColor(lightModeColor: .white, darkModeColor: .black)
        
        // Navigationbar
        let datePicker = UIDatePicker()
        datePicker.date = Date()
        datePicker.datePickerMode = .date
        datePicker.backgroundColor = UIColor.clear
        datePicker.tintColor = UIColor.B1
        datePicker.setValue(UIColor.white, forKey: "textColor")
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        datePicker.locale = Locale(identifier: "zh_Hant_TW")
        let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "zh_Hant_TW")
            formatter.dateFormat = "yyyy 年 M 月 d 日 EEEE" 
            datePicker.addTarget(self, action: #selector(updateDateDisplay), for: .valueChanged)
        
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
        
        // 在 ipad 和模擬器禁用 suggestionAPI 避免 crash
#if !targetEnvironment(simulator)
    if UIDevice.current.userInterfaceIdiom == .phone {
        // 啟用按鈕並設定屬性
        suggestionsButton.isHidden = false
        suggestionsButton.isEnabled = true
        setupSuggestionsButton()
    } else {
        // 在 iPad 上禁用按鈕
        disableSuggestionsButton()
    }
#else
    // 在模擬器上禁用按鈕
    disableSuggestionsButton()
#endif
        
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
    
    func setupSuggestionsButton() {
        suggestionsButton.setImage(UIImage(systemName: "wand.and.stars")?.withTintColor(UIColor.systemGray, renderingMode: .alwaysOriginal), for: .normal)
        suggestionsButton.setTitle("靈感", for: .normal)
        suggestionsButton.tintColor = UIColor.systemGray
        suggestionsButton.titleLabel?.textAlignment = .center
        suggestionsButton.addTarget(self, action: #selector(didTapSuggestionsButton), for: .touchUpInside)
    }

    func disableSuggestionsButton() {
        suggestionsButton.isHidden = true
        suggestionsButton.isEnabled = false
    }
    
    func setupConstraints() {
        // 使用 keyboardLayoutGuide 設定 containerView 的底部約束
        bottomConstraint = buttonContainerView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        bottomConstraint?.isActive = true

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
            buttonContainerView.heightAnchor.constraint(equalToConstant: 50)
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
            textView.textColor = view.traitCollection.userInterfaceStyle == .dark ? .white : .black
        } else if textView === bodyTextView && textView.text == bodyPlaceholder {
            textView.text = nil
            textView.textColor = view.traitCollection.userInterfaceStyle == .dark ? .white : .black
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
    
    
    // MARK: - Update UI
    func updateUI(with journal: Journal) {
        titleTextView.text = journal.title

        let placeholderColor: UIColor = view.traitCollection.userInterfaceStyle == .dark ? .lightGray : .darkGray
        titleTextView.textColor = journal.title.isEmpty ? placeholderColor : (view.traitCollection.userInterfaceStyle == .dark ? .white : .black)

        if titleTextView.text == titlePlaceholder {
            titleTextView.textColor = placeholderColor
        }

        // 設定圖片相關變數
        selectedImages = journal.images
        selectedImageURLs = journal.imageUrls
        selectedDate = journal.date
        selectedPlace = journal.place
        selectedCity = journal.city
        
        // 先設定純文字內容
        let attributedString = NSMutableAttributedString(string: journal.body)
        let textViewFont = bodyTextView.font ?? UIFont.systemFont(ofSize: 24)
        let range = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttribute(.font, value: textViewFont, range: range)

        bodyTextView.attributedText = attributedString
        bodyTextView.textColor = journal.body.isEmpty ? placeholderColor : (view.traitCollection.userInterfaceStyle == .dark ? .white : .black)

        if bodyTextView.text == bodyPlaceholder {
            bodyTextView.textColor = placeholderColor
        }
        
        // 載入圖片（如果有的話）
        downloadAndInsertImagesIntoTextView()
    }
    
    func updateTextViews(title: String, body: String) {
        let titleFont = UIFont.boldSystemFont(ofSize: 30)
        let bodyFont = UIFont.systemFont(ofSize: 24)

        titleTextView.font = titleFont
        titleTextView.text = title
        titleTextView.textColor = view.traitCollection.userInterfaceStyle == .dark ? .white : .black

        bodyTextView.font = bodyFont
        bodyTextView.text = body
        bodyTextView.textColor = view.traitCollection.userInterfaceStyle == .dark ? .white : .black
    }
    
    //MARK: - Action
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func dateChanged(_ datePicker: UIDatePicker) {
        selectedDate = datePicker.date
    }
    
    @objc func updateDateDisplay(_ datePicker: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hant_TW")
        formatter.dateFormat = "yyyy 年 M 月 d 日 EEEE"
        let formattedDate = formatter.string(from: datePicker.date)
        print("日期格式 : \(formattedDate)")
    }
    
    func uploadImagesToStorage(completion: @escaping ([String]) -> Void) {
        var imageUrls: [String] = []
        
        let dispatchGroup = DispatchGroup()
        for image in selectedImages {
            if let existingUrl = journal?.imageUrls.first(where: { url in
                url == image.accessibilityIdentifier
            }) {
                imageUrls.append(existingUrl)
            } else {
                dispatchGroup.enter()
                uploadImage(image) { result in
                    switch result {
                    case .success(let url):
                        imageUrls.append(url.absoluteString)
                        image.accessibilityIdentifier = url.absoluteString
                    case .failure(let error):
                        print("上傳圖片失敗 : \(error)")
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(imageUrls)
        }
    }
    
    
    func uploadImage(_ image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        let storageRef = Storage.storage().reference().child("journal_images").child(UUID().uuidString + ".jpg")
        
        print("開始上傳圖片...")
        
        if let uploadData = image.jpegData(compressionQuality: 0.8) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            storageRef.putData(uploadData, metadata: metadata) { (metadata, error) in
                if let error = error {
                    print("上傳圖片失敗: \(error)")
                    completion(.failure(error))
                } else {
                    print("圖片上傳成功，正在獲取下載 URL...")
                    storageRef.downloadURL { (url, error) in
                        if let error = error {
                            print("獲取下載 URL 失敗: \(error)")
                            completion(.failure(error))
                        } else if let url = url {
                            print("獲取下載 URL 成功: \(url)")
                            completion(.success(url))
                        }
                    }
                }
            }
        }
    }
    
    
    @objc func doneButtonTapped() {
        if navigationItem.rightBarButtonItem?.isEnabled == false {
            return
        }
        
        
        // 禁用按鈕，避免重複點擊
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        if let title = titleTextView.text, let body = bodyTextView.text, let date = selectedDate {
            // 檢查日記是否有變更（提取純文字內容進行比較）
            let bodyPlainText = bodyTextView.attributedText?.string ?? body
            let originalImagesCount = journal?.images.count ?? 0
            if title == journal?.title && bodyPlainText == journal?.body && selectedImages.count == originalImagesCount {
                // 日記內容沒有變更，不需要上傳到 Firebase
                self.navigationController?.popViewController(animated: true)
                return
            }
            
            view.showLoadingAnimation()
            uploadImagesToStorage { [weak self] imageUrls in
                guard let self = self else { return }
                let newJournal = Journal(id: self.journal?.id ?? UUID(), title: title, body: body, date: date, images: self.selectedImages, place: self.selectedPlace, city: self.selectedCity, imageUrls: imageUrls)
                
                // 獲取用戶的 UID
                if let currentUser = Auth.auth().currentUser {
                    let userId = currentUser.uid
                    
                    FirestoreService.shared.uploadJournal(userId: userId, journal: newJournal) { result in
                        switch result {
                        case .success():
                            print("日記上傳成功")
                            NotificationCenter.default.post(name: .newJournalEntrySaved, object: nil, userInfo: ["journal": newJournal])
                            self.navigationController?.popViewController(animated: true)
                        case .failure(let error):
                            print("日記上傳失敗: \(error)")
                        }
                        
                        // 不管成功或失敗，重新啟用按鈕
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                    }
                }
            }
        } else {
            print("Error: 錯誤資訊")
            
            // 發生錯誤，也重新啟用按鈕
            navigationItem.rightBarButtonItem?.isEnabled = true
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
                        print("已處理圖片並加入 array. 目前總共: \(self?.selectedImages.count ?? 0)")
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
            view.showLoadingAnimation()
            resizeImage(image, targetWidth: bodyTextView.bounds.width / 2) { [weak self] resizedImage in
                if let resizedImage = resizedImage {
                    self?.selectedImages.append(resizedImage)
                    self?.insertImage(resizedImage)
                    self?.uploadImage(resizedImage) { result in
                        switch result {
                        case .success(let url):
                            self?.selectedImageURLs.append(url.absoluteString)
                        case .failure(let error):
                            print("Failed to upload image: \(error)")
                        }
                        processedImagesCount += 1
                        print("處理所有 \(totalImages) 圖片中的第 \(processedImagesCount) 圖片")
                        self?.view.hideLoadingAnimation()
                        if processedImagesCount == totalImages {
                            print("處理完所有圖片.")
                            self?.imagesReadyToSave = true
                            self?.downloadAndInsertImagesIntoTextView()
                        }
                    }
                }
            }
        }
    }
    
    // 從 Firebase 下載圖片並插入 TextView
    func downloadAndInsertImagesIntoTextView() {
        guard !selectedImageURLs.isEmpty else { 
            print("沒有圖片 URL 需要下載")
            return 
        }
        
        let attributedString = NSMutableAttributedString(attributedString: bodyTextView.attributedText ?? NSAttributedString())
        
        let textViewFont = bodyTextView.font ?? UIFont.systemFont(ofSize: 24)
        let textViewAttributes: [NSAttributedString.Key: Any] = [
            .font: textViewFont
        ]
        
        if isNewDiary {
            // 新增日記 - 圖片已經在 insertImage 方法中插入，不需要額外處理
            print("新增日記，圖片已經插入，不需要下載和插入")
        } else {
            // 開啟舊日記 - 需要從 Firebase 下載圖片
            print("開啟舊日記，準備下載 \(selectedImageURLs.count) 張圖片")
            let group = DispatchGroup()
            var attachments: [(NSTextAttachment, Int)] = []
            
            for (index, imageURL) in selectedImageURLs.enumerated() {
                print("準備下載圖片 \(index + 1): \(imageURL)")
                if let url = URL(string: imageURL), !isImageAlreadyInserted(imageURL: imageURL) {
                    group.enter()
                    
                    let attachment = NSTextAttachment()
                    attachments.append((attachment, index))
                    
                    KingfisherManager.shared.retrieveImage(with: url, options: [.transition(.fade(0.3))], progressBlock: nil) { result in
                        switch result {
                        case .success(let value):
                            attachment.image = value.image
                            print("成功下載圖片 \(index + 1): \(imageURL)")
                        case .failure(let error):
                            print("下載圖片 \(index + 1) 錯誤: \(error)")
                        }
                        group.leave()
                    }
                } else {
                    print("跳過下載圖片 \(index + 1) (已存在)")
                }
            }
            
            // 等待所有圖片下載完成後一次性更新 UI
            group.notify(queue: .main) {
                guard let currentAttributedText = self.bodyTextView.attributedText else { return }
                let mutableAttributedString = NSMutableAttributedString(attributedString: currentAttributedText)
                
                for (attachment, index) in attachments {
                    if attachment.image != nil {
                        let attachmentString = NSAttributedString(attachment: attachment)
                        
                        mutableAttributedString.append(NSAttributedString(string: "\n", attributes: textViewAttributes))
                        mutableAttributedString.append(attachmentString)
                        mutableAttributedString.append(NSAttributedString(string: "\n", attributes: textViewAttributes))
                        print("已插入圖片 \(index + 1) 到 TextView")
                    } else {
                        print("圖片 \(index + 1) 下載失敗，跳過插入")
                    }
                }
                
                self.bodyTextView.attributedText = mutableAttributedString
                print("已完成所有 \(attachments.count) 張圖片的下載和插入")
            }
        }
    }

    func isImageAlreadyInserted(imageURL: String) -> Bool {
        // 當載入舊日記時，一開始一定沒有圖片，都需要從 Firebase 下載
        return false
    }

    // 在 textView 插入圖片並 resize
    func insertImage(_ image: UIImage) {
        DispatchQueue.main.async {
            // 檢查圖片是否已經存在於 TextView 中
            if let imageId = image.accessibilityIdentifier,
               self.bodyTextView.text.contains(imageId) {
                print("圖片已經存在 TextView")
                return
            }

            let textAttachment = NSTextAttachment()
            textAttachment.image = image
            
            // 設定圖片的 accessibilityIdentifier 來區別圖片
            if image.accessibilityIdentifier == nil {
                image.accessibilityIdentifier = UUID().uuidString
            }

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: self.bodyTextView.font!,
                .paragraphStyle: paragraphStyle
            ]
            
            let attributedStringWithImage = NSAttributedString(attachment: textAttachment)
            let imageString = NSMutableAttributedString(attributedString: attributedStringWithImage)
            imageString.addAttributes(attrs, range: NSRange(location: 0, length: imageString.length))
            
            let mutableAttributedString = NSMutableAttributedString(attributedString: self.bodyTextView.attributedText ?? NSAttributedString())
            
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
