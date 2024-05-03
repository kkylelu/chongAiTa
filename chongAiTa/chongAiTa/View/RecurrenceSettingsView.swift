//
//  RecurrenceSettingsView.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/23.
//

import UIKit

class RecurrenceSettingsView: UIView {
    
    let recurrenceTypes = ["每天", "每週", "每月", "每年", "不重複"]
    var selectedRecurrence: Recurrence?
    var eventDetailViewController: EventDetailViewController?
    
    var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }()
    
    var selectedRecurrenceLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
    
    var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("確認", for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.B1
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    
    func setupUI() {
        backgroundColor = .white
        
        addSubview(pickerView)
        addSubview(doneButton)
        addSubview(selectedRecurrenceLabel)
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            pickerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            pickerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            pickerView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            
            selectedRecurrenceLabel.leadingAnchor.constraint(equalTo: doneButton.trailingAnchor, constant: 10),
                    selectedRecurrenceLabel.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor),
            
            doneButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            doneButton.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 20),
            doneButton.widthAnchor.constraint(equalTo: pickerView.widthAnchor, multiplier: 0.8),
            doneButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Actions
    
    @objc func doneButtonTapped() {
        // 獲取選擇的重複設置
        let selectedRow = pickerView.selectedRow(inComponent: 0)
        switch selectedRow {
        case 0:
                selectedRecurrence = .daily
                selectedRecurrenceLabel.text = "每天"
            case 1:
                selectedRecurrence = .weekly
                selectedRecurrenceLabel.text = "每週"
            case 2:
                selectedRecurrence = .monthly
                selectedRecurrenceLabel.text = "每月"
            case 3:
                selectedRecurrence = .yearly
                selectedRecurrenceLabel.text = "每年"
            case 4:
                selectedRecurrenceLabel.text = "不重複"
        default:
            break
        }
        
        
        // 將選擇的重複設定傳回給 EventDetailViewController
        eventDetailViewController?.selectedRecurrence = selectedRecurrence
        
        removeFromSuperview()
        
    }
}

// MARK: - UIPickerViewDelegate

extension RecurrenceSettingsView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return recurrenceTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return recurrenceTypes[row]
    }
}

