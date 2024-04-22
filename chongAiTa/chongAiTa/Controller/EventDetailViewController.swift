//
//  EventDetailViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/20.
//

import UIKit

class EventDetailViewController: UIViewController,UINavigationControllerDelegate {
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
    
    var eventImage: UIImage?
    var eventTitle: String?
    var eventDate: Date?
    var selectedActivity: DefaultActivity?
    var currentEventId: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        addSubviews(to: containerView)
        displayEventDetails()
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
            containerView.widthAnchor.constraint(equalToConstant: 300),
            containerView.heightAnchor.constraint(equalToConstant: 530)
        ])
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
        costTextField.translatesAutoresizingMaskIntoConstraints = false
        
        timeLabel.text = "紀錄時間"
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(titleTextField)
        containerView.addSubview(noteLabel)
        containerView.addSubview(noteTextView)
        containerView.addSubview(costLabel)
        containerView.addSubview(costTextField)
        containerView.addSubview(timeLabel)
        containerView.addSubview(datePicker)
        
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
            datePicker.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 10)
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
        datePicker.date = eventDate ?? Date()
    }
    
    // MARK: - Action
    @objc func doneButtonTapped() {
        print("Selected Activity: \(selectedActivity)")
           print("Current Event ID: \(currentEventId)")
        
        let cost = Double(costTextField.text ?? "") ?? 0.0
        if let activity = selectedActivity,
           let currentId = currentEventId {
            
            var title: String
                    
                    if let titleText = titleTextField.text, !titleText.isEmpty {
                        // 如果有編輯標題，則使用編輯後的標題
                        title = titleText
                    } else if let originalTitle = eventTitle {
                        // 如果沒有編輯標題，原本的標題不是空值，則保留原本的標題
                        title = originalTitle
                    } else {
                        // 如果沒有編輯標題，原本的標題為空值，則使用活動類別的顯示名稱
                        title = activity.category.displayName
                    }
            
            let event = CalendarEvents(
                id: currentId,
                title: title,
                date: datePicker.date,
                activity: activity,
                content: noteTextView.text,
                image: iconImageView.image,
                cost: cost
            )
            
            
            if EventsManager.shared.loadEvents(for: event.date).contains(where: { $0.id == event.id }) {
                EventsManager.shared.updateEvent(event)
                print("Updating event: \(event)")
            } else {
                EventsManager.shared.saveEvent(event)
                print("Saving new event: \(event)")
            }

            print("Event Saved/Updated: \(event.title), Date: \(event.date)")
            
            if let navigationController = navigationController {
                for controller in navigationController.viewControllers {
                    if let calendarDateVC = controller as? CalendarDateViewController {
                        calendarDateVC.selectedDate = datePicker.date
                        calendarDateVC.loadEvents()
                        print("Data source for CalendarDateViewController should be updated now.")
                        navigationController.popToViewController(calendarDateVC, animated: true)
                        return
                    }
                }
            }
        }
    }


}
