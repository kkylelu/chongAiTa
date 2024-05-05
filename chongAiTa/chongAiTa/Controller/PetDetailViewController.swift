//
//  PetDetailViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/25.
//

import UIKit
import MobileCoreServices
import FirebaseStorage
import FirebaseFirestore
import Kingfisher
import FirebaseAuth

class PetDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var pet: Pet?
    var pets: [Pet] = []
    var pickerView = UIPickerView()
    var currentPickerType: PickerType?
    var currentPetIndex: Int?
    var pickerData: [String] = ["選項1", "選項2", "選項3"]
    var imagePickerController = UIImagePickerController()
    var isPetDataChanged = false
    
    enum PickerType {
        case gender, type, neutered
    }
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(PetDetailTableViewCell.self, forCellReuseIdentifier: PetDetailTableViewCell.reuseIdentifier)
        return tableView
    }()
    
    let petImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 75
        return imageView
    }()
    
    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.B1
        view.layer.cornerRadius = 100
        return view
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addNewPets))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(goSettingPage))
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        setupUI()
        setNavigationTitle(.pet)
        fetchPetDataFromFirebase {_ in
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if pet == nil {
            fetchPetDataFromFirebase { [weak self] hasData in
                if !hasData {
                    // 如果 Firebase 中沒有資料，則加載假資料
                    self?.loadFakeData()
                }
            }
        }
        
        updateInfoLabelText()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let currentUser = Auth.auth().currentUser {
            let userId = currentUser.uid
            
            if isPetDataChanged, let currentPet = pet {
                FirestoreService.shared.uploadPet(userId: userId, pet: currentPet) { error in
                    if let error = error {
                        print("Error uploading pet data: \(error.localizedDescription)")
                    } else {
                        print("Pet data uploaded successfully")
                        self.isPetDataChanged = false
                        
                        // 上傳完成後重新獲取寵物資料
                        self.fetchPetDataFromFirebase { _ in
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.updateImageView(with: currentPet.imageUrl)
                                self.updateInfoLabelText()
                            }
                        }
                    }
                }
            }
        }
    }

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    // MARK: - Setup UI
    func setupUI() {
        applyDynamicBackgroundColor(lightModeColor: .white, darkModeColor: .black)
        setupTableViewBackgroundColor()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        petImageView.isUserInteractionEnabled = true
        petImageView.addGestureRecognizer(tapGesture)
        
        let imagePickerButton = UIButton(type: .custom)
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        let image = UIImage(systemName: "camera.circle.fill", withConfiguration: config)
        imagePickerButton.setImage(image, for: .normal)
        imagePickerButton.tintColor = UIColor.B1
        imagePickerButton.imageView?.contentMode = .scaleAspectFit
        imagePickerButton.addTarget(self, action: #selector(imagePickerButtonTapped), for: .touchUpInside)
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        view.addSubview(tableView)
        view.addSubview(backgroundView)
        view.addSubview(petImageView)
        view.addSubview(imagePickerButton)
        view.addSubview(infoLabel)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        petImageView.translatesAutoresizingMaskIntoConstraints = false
        imagePickerButton.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            petImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            petImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            petImageView.widthAnchor.constraint(equalToConstant: 150),
            petImageView.heightAnchor.constraint(equalToConstant: 150),
            
            imagePickerButton.widthAnchor.constraint(equalToConstant: 50),
            imagePickerButton.heightAnchor.constraint(equalToConstant: 50),
            imagePickerButton.trailingAnchor.constraint(equalTo: petImageView.trailingAnchor, constant: 10),
            imagePickerButton.bottomAnchor.constraint(equalTo: petImageView.bottomAnchor, constant: 10),
            
            backgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: petImageView.centerYAnchor, constant:  -200),
            backgroundView.widthAnchor.constraint(equalToConstant: 450),
            backgroundView.heightAnchor.constraint(equalToConstant: 450),
            
            infoLabel.topAnchor.constraint(equalTo: petImageView.bottomAnchor, constant: 26),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 3),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            
        ])
        
    }
    
    private func setupTableViewBackgroundColor() {
        if #available(iOS 13.0, *) {
            tableView.backgroundColor = UIColor { (traitCollection) -> UIColor in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return .black
                default:
                    return .white
                }
            }
        } else {
            view.backgroundColor = .white
        }
    }
    
    func loadFakeData() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let fakePet = Pet(image: "mydog",
                          imageUrl: [],
                          name: "熊熊",
                          gender: .male,
                          type: .dog,
                          breed: "米克斯",
                          birthday: dateFormatter.date(from: "2016-07-10"),
                          joinDate: dateFormatter.date(from: "2020-03-10"),
                          weight: 13.0,
                          isNeutered: true)
        setPet(fakePet)
    }
    
    func setPet(_ pet: Pet) {
        self.pet = pet
        if let imageUrl = pet.imageUrl.first {
            petImageView.kf.setImage(with: URL(string: imageUrl))
        } else {
            petImageView.image = UIImage(named: pet.image ?? "ShibaInuIcon")
        }
        tableView.reloadData()
    }
    
    // MARK: - Update UI
    func updateImageView(with imageUrls: [String]) {
        guard let imageUrl = imageUrls.first else {
            petImageView.image = UIImage(named: "ShibaInuIcon")
            return
        }
        
        petImageView.kf.setImage(with: URL(string: imageUrl))
    }
    
    func updateInfoLabelText() {
        guard let pet = pet else {
            infoLabel.text = ""
            return
        }
        
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: pet.birthday ?? Date(), to: Date())
        let age = ageComponents.year ?? 0
        
        let joinedComponents = calendar.dateComponents([.day], from: pet.joinDate ?? Date(), to: Date())
        let joinedDays = joinedComponents.day ?? 0
        
        infoLabel.text = "／我今年 \(age) 歲，來到家裡 \(joinedDays) 天囉＼"
    }
    
    // MARK: - Action
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        presentImagePicker()
    }
    
    @objc func imagePickerButtonTapped() {
        presentImagePicker()
    }
    
    func uploadImageToFirebaseStorage(image: UIImage) {
        resizeImage(image, targetWidth: 800) { resizedImage in
            guard let resizedImage = resizedImage,
                  let imageData = resizedImage.jpegData(compressionQuality: 0.8) else {
                return
            }
            
            // 使用壓縮後的圖片數據進行上傳
            let storageRef = Storage.storage().reference().child("petImages/\(UUID().uuidString).jpg")
            
            // 設置圖片的 metadata
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            storageRef.putData(imageData, metadata: metadata) { (metadata, error) in
                if let error = error {
                    print("上傳圖片失敗: \(error.localizedDescription)")
                    return
                }
                
                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        print("取得圖片 URL 失敗: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let imageUrl = url?.absoluteString else {
                        return
                    }
                    
                    self.pet?.imageUrl = [imageUrl]
                    self.isPetDataChanged = true
                }
                
            }
        }
    }
    
    
    func resizeImage(_ image: UIImage, targetWidth: CGFloat, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            let size = image.size
            let scaleFactor = targetWidth / size.width
            let newHeight = size.height * scaleFactor
            let newSize = CGSize(width: targetWidth, height: newHeight)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            DispatchQueue.main.async {
                completion(resizedImage)
            }
        }
    }
    
    func showPicker(for type: PickerType) {
        currentPickerType = type
        
        switch type {
        case .gender:
            pickerData = Pet.Gender.allCases.map { $0.rawValue }
        case .type:
            pickerData = Pet.PetType.allCases.map { $0.displayName }
        case .neutered:
            pickerData = ["已結紮", "未結紮"]
        }
        
        let pickerViewController = UIViewController()
        pickerViewController.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 260)
        pickerViewController.view.addSubview(pickerView)
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.reloadAllComponents()
        
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pickerView.leadingAnchor.constraint(equalTo: pickerViewController.view.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: pickerViewController.view.trailingAnchor),
            pickerView.topAnchor.constraint(equalTo: pickerViewController.view.topAnchor),
            pickerView.bottomAnchor.constraint(equalTo: pickerViewController.view.bottomAnchor)
        ])
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.setValue(pickerViewController, forKey: "contentViewController")
        
        let doneAction = UIAlertAction(title: "確定", style: .default) { [unowned self] _ in
            let selectedRow = pickerView.selectedRow(inComponent: 0)
            self.pickerView(pickerView, didSelectRow: selectedRow, inComponent: 0)
            dismiss(animated: true, completion: nil)
            tableView.reloadData()
        }
        
        alertController.addAction(doneAction)
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(alertController, animated: true)
    }
    
    
    @objc func pickerDoneButtonTapped() {
        dismissPicker()
        tableView.reloadData()
    }
    
    @objc func pickerCancelButtonTapped() {
        dismissPicker()
    }
    
    func dismissPicker() {
        guard let pickerContainer = view.subviews.last else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            pickerContainer.frame.origin.y = self.view.bounds.height
        }, completion: { _ in
            pickerContainer.removeFromSuperview()
        })
    }
    
    func showTextFieldAlert(for item: PetDetailItem) {
        let alertController = UIAlertController(title: "輸入\(item.title)", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "請輸入\(item.title)"
            if item == .name {
                textField.text = self.pet?.name
            } else if item == .breed {
                textField.text = self.pet?.breed
            }
        }
        
        let saveAction = UIAlertAction(title: "確定", style: .default) { _ in
            if let textField = alertController.textFields?.first,
               let text = textField.text {
                switch item {
                case .name:
                    self.pet?.name = text
                case .breed:
                    self.pet?.breed = text
                default:
                    break
                }
                self.tableView.reloadData()
                self.isPetDataChanged = true
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showDatePicker(for item: PetDetailItem) {
        let datePickerViewController = UIViewController()
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "zh_TW")
        datePickerViewController.view.addSubview(datePicker)
        datePickerViewController.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 260)
        
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: datePickerViewController.view.centerXAnchor),
            datePicker.centerYAnchor.constraint(equalTo: datePickerViewController.view.centerYAnchor),
            datePicker.widthAnchor.constraint(equalTo: datePickerViewController.view.widthAnchor)
        ])
        
        // 設置初始日期
        if let date = (item == .birthday ? pet?.birthday : pet?.joinDate) {
            datePicker.date = date
        }
        
        let alertController = UIAlertController(title: "選擇\(item.title)", message: nil, preferredStyle: .actionSheet)
        alertController.setValue(datePickerViewController, forKey: "contentViewController")
        
        let saveAction = UIAlertAction(title: "確定", style: .default) { [unowned self] _ in
            let selectedDate = datePicker.date
            
            if item == .birthday {
                self.pet?.birthday = selectedDate
            } else if item == .joinDate {
                self.pet?.joinDate = selectedDate
            }
            
            self.tableView.reloadData()
            updateInfoLabelText()
            self.isPetDataChanged = true
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        present(alertController, animated: true)
    }
    
    
    func showNumberPadAlert(for item: PetDetailItem) {
        let alertController = UIAlertController(title: "輸入\(item.title)", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "請輸入\(item.title)"
            textField.keyboardType = .decimalPad
            if item == .weight, let weight = self.pet?.weight {
                textField.text = "\(weight)"
            }
        }
        
        let saveAction = UIAlertAction(title: "確定", style: .default) { _ in
            if let textField = alertController.textFields?.first,
               let text = textField.text,
               let weight = Double(text) {
                self.pet?.weight = weight
                self.tableView.reloadData()
                self.isPetDataChanged = true
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func presentImagePicker() {
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func savePetData() {
        guard let currentPet = pet else {
            print("目前沒有寵物資料可以儲存。")
            return
        }
        if let currentUser = Auth.auth().currentUser {
            let userId = currentUser.uid
            
            print("正在嘗試上傳寵物資料: \(currentPet)")
            FirestoreService.shared.uploadPet(userId: userId, pet: currentPet) { error in
                if let error = error {
                    print("上傳寵物資料失敗: \(error.localizedDescription)")
                } else {
                    print("寵物資料成功上傳至雲端。")
                    self.isPetDataChanged = false
                    // 重新載入 tableView
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func fetchPetDataFromFirebase(completion: @escaping (Bool) -> Void) {
        guard let petName = pet?.name else {
            print("No pet name available")
            loadFakeData()
            completion(false)
            return
        }
        
        if let currentUser = Auth.auth().currentUser {
            let userId = currentUser.uid
            FirestoreService.shared.fetchPet(userId: userId, petName: petName) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let fetchedPet):
                        self?.setPet(fetchedPet)
                        self?.updateImageView(with: fetchedPet.imageUrl)
                        self?.updateInfoLabelText()
                        self?.tableView.reloadData()
                        completion(true)
                        
                    case .failure(let error):
                        print("Error fetching pet: \(error.localizedDescription)")
                        self?.loadFakeData()
                        completion(false)
                    }
                }
            }
        }
    }

    
    @objc func addNewPets(){
        print("tapped addNewPets function")
    }
    
    @objc func goSettingPage(){
        let userVC = UserProfileViewController()
        navigationController?.pushViewController(userVC, animated: true)
    }
    
    // MARK: - TableView Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            return 4
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PetDetailTableViewCell.reuseIdentifier, for: indexPath) as? PetDetailTableViewCell else {
            print("Error: Cell is not of type PetDetailTableViewCell at row \(indexPath.row)")
            return UITableViewCell()
        }
        
        let item = PetDetailItem.forIndexPath(indexPath)
        if let pet = pet {
            cell.configure(with: item, pet: pet)
        } else {
            print("No pet data available for row \(indexPath.row)")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = PetDetailItem.forIndexPath(indexPath)
        switch item {
        case .gender:
            showPicker(for: .gender)
        case .type:
            showPicker(for: .type)
        case .isNeutered:
            showPicker(for: .neutered)
        case .name, .breed:
            showTextFieldAlert(for: item)
        case .birthday, .joinDate:
            showDatePicker(for: item)
        case .weight:
            showNumberPadAlert(for: item)
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        isPetDataChanged = true
    }
    
    // MARK: - PickerView Delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let currentPickerType = currentPickerType else { return }
        
        switch currentPickerType {
        case .gender:
            pet?.gender = Pet.Gender.allCases[row]
        case .type:
            pet?.type = Pet.PetType.allCases[row]
        case .neutered:
            pet?.isNeutered = (row == 0)
        }
    }
    
    // MARK: - ImagePicker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            petImageView.image = editedImage
            uploadImageToFirebaseStorage(image: editedImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
            petImageView.image = originalImage
            uploadImageToFirebaseStorage(image: originalImage)
        }
        isPetDataChanged = true
        dismiss(animated: true, completion: nil)
    }
}
