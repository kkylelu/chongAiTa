//
//  EventDetailViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/20.
//

import UIKit
import FirebaseFirestore

class EventDetailViewController: UIViewController,UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    let containerView = UIView()
    var iconImageView = UIImageView()
    var titleLabel = UILabel()
    var titleTextField = UITextField()
    var noteLabel = UILabel()
    var noteTextView = UITextView()
    var costLabel = UILabel()
    var costTextField = UITextField()
    var timeLabel = UILabel()
    var datePicker = UIDatePicker()
    var doneButton: UIButton!
    
    var eventImage: UIImage?
    var eventTitle: String?
    var eventDate: Date?
    var selectedActivity: DefaultActivity?
    var selectedRecurrence: Recurrence?
    var recurrenceButton: UIButton!
    var currentEventId: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        addSubviews(to: containerView)
        displayEventDetails()
        titleTextField.delegate = self
        costTextField.delegate = self
        noteTextView.delegate = self
    }
    
    // MARK: - Setup UI
    
    func setupUI() {
        view.backgroundColor = .white
        
        let rightBarButtonItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(doneButtonTapped))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.B1
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = UIColor.white
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 10
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: -1)
        containerView.layer.shadowRadius = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 350),
            containerView.heightAnchor.constraint(equalToConstant: 650)
        ])
        
        doneButton = UIButton(type: .system)
        doneButton.setTitle("完成", for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        doneButton.backgroundColor = UIColor.B1
        doneButton.layer.cornerRadius = 10
        doneButton.tintColor = .white
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(doneButton)
    }
    
    func addSubviews(to containerView: UIView) {
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleTextField.placeholder = "輸入標題或保留預設值"
        titleTextField.borderStyle = .roundedRect
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        
        noteLabel.text = "內容備註"
        noteLabel.translatesAutoresizingMaskIntoConstraints = false
        
        noteTextView.layer.borderColor = UIColor.systemGray6.cgColor
        noteTextView.layer.borderWidth = 1.0
        noteTextView.layer.cornerRadius = 5
        noteTextView.translatesAutoresizingMaskIntoConstraints = false
        
        costLabel.text = "花費金額"
        costLabel.translatesAutoresizingMaskIntoConstraints = false
        
        costTextField.placeholder = "輸入金額"
        costTextField.borderStyle = .roundedRect
        costTextField.keyboardType = .numberPad
        costTextField.translatesAutoresizingMaskIntoConstraints = false
        
        timeLabel.text = "紀錄時間"
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        recurrenceButton = UIButton(type: .system)
        recurrenceButton.setTitle("設定重複活動", for: .normal)
        recurrenceButton.tintColor = .black
        recurrenceButton.addTarget(self, action: #selector(showRecurrenceSettings), for: .touchUpInside)
        recurrenceButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(recurrenceButton)
        containerView.addSubview(doneButton)
        
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(titleTextField)
        containerView.addSubview(noteLabel)
        containerView.addSubview(noteTextView)
        containerView.addSubview(costLabel)
        containerView.addSubview(costTextField)
        containerView.addSubview(timeLabel)
        containerView.addSubview(datePicker)
        containerView.addSubview(recurrenceButton)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: 60),
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            titleTextField.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            titleTextField.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8),
            
            noteLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            noteLabel.leadingAnchor.constraint(equalTo: noteTextView.leadingAnchor),
            
            noteTextView.topAnchor.constraint(equalTo: noteLabel.bottomAnchor, constant: 5),
            noteTextView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            noteTextView.heightAnchor.constraint(equalToConstant: 100),
            noteTextView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8),
            
            costLabel.topAnchor.constraint(equalTo: noteTextView.bottomAnchor, constant: 20),
            costLabel.leadingAnchor.constraint(equalTo: noteLabel.leadingAnchor),
            
            costTextField.topAnchor.constraint(equalTo: costLabel.bottomAnchor, constant: 10),
            costTextField.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            costTextField.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8),
            
            timeLabel.topAnchor.constraint(equalTo: costTextField.bottomAnchor, constant: 20),
            timeLabel.leadingAnchor.constraint(equalTo: noteLabel.leadingAnchor),
            
            datePicker.leadingAnchor.constraint(equalTo: timeLabel.leadingAnchor),
            datePicker.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 10),
            
            recurrenceButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 10),
            recurrenceButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            doneButton.topAnchor.constraint(equalTo: recurrenceButton.bottomAnchor, constant: 20),
            doneButton.leadingAnchor.constraint(equalTo: costTextField.leadingAnchor),
            doneButton.trailingAnchor.constraint(equalTo: costTextField.trailingAnchor),
            doneButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func configure(event: CalendarEvents) {
        self.eventImage = event.image
        self.eventTitle = event.title
        self.eventDate = event.date
        self.selectedActivity = event.activity
        self.currentEventId = event.id
        displayEventDetails()
    }
    
    func displayEventDetails() {
        iconImageView.image = eventImage
        titleLabel.text = eventTitle
        
        // 檢查是否有傳來的 eventDate
        if let eventDate = eventDate {
            // 使用傳來的日期，但設定時間為上午 9:00
            var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: eventDate)
            dateComponents.hour = 9
            dateComponents.minute = 0
            datePicker.date = Calendar.current.date(from: dateComponents) ?? eventDate
        } else {
            // 如果沒有傳遞日期，則使用當天日期並設為上午 9:00
            let now = Date()
            var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: now)
            dateComponents.hour = 9
            dateComponents.minute = 0
            datePicker.date = Calendar.current.date(from: dateComponents) ?? now
        }
    }
    
    // MARK: - Action
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func showRecurrenceSettings() {
        let recurrenceSettingsView = RecurrenceSettingsView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height / 2))
        recurrenceSettingsView.center = view.center
        recurrenceSettingsView.eventDetailViewController = self
        view.addSubview(recurrenceSettingsView)
        
        // 當 RecurrenceSettingsView 關閉時,更新 recurrenceButton 的標題
        recurrenceSettingsView.doneButton.addTarget(self, action: #selector(updateRecurrenceButtonTitle), for: .touchUpInside)
    }
    
    @objc func updateRecurrenceButtonTitle() {
        if let selectedRecurrence = selectedRecurrence {
            switch selectedRecurrence {
            case .daily:
                recurrenceButton.setTitle("每天重複", for: .normal)
            case .weekly:
                recurrenceButton.setTitle("每週重複", for: .normal)
            case .monthly:
                recurrenceButton.setTitle("每月重複", for: .normal)
            case .yearly:
                recurrenceButton.setTitle("每年重複", for: .normal)
            }
        } else {
            recurrenceButton.setTitle("設定重複活動", for: .normal)
        }
    }
    
    @objc func doneButtonTapped() {
        let cost = Double(costTextField.text ?? "") ?? 0.0
        if let activity = selectedActivity, let currentId = currentEventId {
            let title = titleTextField.text?.isEmpty ?? true ? (eventTitle ?? activity.category.displayName) : titleTextField.text!
            
            let event = CalendarEvents(
                id: currentId,
                title: title,
                date: datePicker.date,
                activity: activity,
                content: noteTextView.text,
                image: iconImageView.image,
                cost: cost,
                recurrence: selectedRecurrence
            )
            
            if !EventsManager.shared.hasEvent(event) {
                EventsManager.shared.saveEvents([event])
                NotificationCenter.default.post(name: .didCreateEvent, object: event)
                
                FirestoreService.shared.uploadEvent(event) { [weak self] result in
                    print(result)
                    
                    switch result {
                    case .success():
                        print("活動成功上傳到 Firestore。")
                    case .failure(let error):
                        print("上傳到 Firestore 時出現錯誤：\(error)")
                    }
                    self?.closeViewController()
                }
            } else {
                closeViewController()
            }
        }
    }
    
    private func closeViewController() {
        if let navController = navigationController, navController.viewControllers.count > 1 {
            navController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - UITextField and TextView Delegate

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.B1.cgColor
        textField.layer.borderWidth = 1.0
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.clear.cgColor
        textField.layer.borderWidth = 0.0
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.layer.borderColor = UIColor.B1.cgColor
        textView.layer.borderWidth = 1.0
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        textView.layer.borderColor = UIColor.systemGray6.cgColor
        textView.layer.borderWidth = 1.0
    }
    
}
