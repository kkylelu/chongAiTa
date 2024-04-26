//
//  ChatBotViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/18.
//

import UIKit
import FirebaseFirestore

class ChatBotViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var tableView: UITableView!
    var textField: UITextField!
    var sendButton: UIButton!
    var quickReplyButtons: [UIButton] = []
    
    var messages: [String] = []
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uploadTestFAQs()
        
        downloadFAQs()
        
        setupUI()
        configureTableView()
        configureQuickReplyButtons()
        
        tableView.register(MessageBubbleTableViewCell.self, forCellReuseIdentifier: "MessageBubbleTableViewCell")
    }
    
    func configureQuickReplyButtons() {
        let messages = ["狗狗會感冒嗎？", "多久要帶狗狗去打疫苗？", "狗狗可以吃巧克力嗎？"]
        
        for message in messages {
            let button = UIButton(type: .system)
            button.setTitle(message, for: .normal)
            button.addTarget(self, action: #selector(quickReplyTapped(_:)), for: .touchUpInside)
            view.addSubview(button)
            quickReplyButtons.append(button)
        }
        
        layoutQuickReplyButtons()
    }
    
    //MARK: - Setup UI
    func configureTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
    }
    
    func setupUI() {
        view.backgroundColor = .white
        
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "messageCell")
        view.addSubview(tableView)
        
        textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        view.addSubview(textField)
        
        sendButton = UIButton(type: .system)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        let sendButtonImage = UIImage(systemName: "paperplane.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .medium))
        sendButton.setImage(sendButtonImage, for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        view.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: textField.topAnchor),
            
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -15),
            textField.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor),
            
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            sendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
            sendButton.widthAnchor.constraint(equalToConstant: 56),
            sendButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    func layoutQuickReplyButtons() {
        let buttonHeight: CGFloat = 40
        // 每個按鈕之間的垂直間距
        let spacing: CGFloat = 50

        for (index, button) in quickReplyButtons.enumerated() {
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -(spacing * CGFloat(index + 1))),
                button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                button.heightAnchor.constraint(equalToConstant: buttonHeight)
            ])
        }
    }
    
    // TODO: - test
    func uploadTestFAQs() {
        let healthEntries = [
            FAQEntry(question: "幼犬為什麼要打多次預防針？", answer: "幼犬需要多次疫苗來刺激產生抗體,預防病毒感染。通常 6 周大就可開始施打,建議跟獸醫討論一下最適合的疫苗計畫喔!🐶")
        ]
        
        let faqCategory = FAQCategory(id: "test_faq", health: healthEntries, nutrition: [], care: [])
        
        FirestoreService.shared.uploadFAQCategory(faqCategory) { result in
            switch result {
            case .success:
                print("Successfully uploaded test FAQ data")
            case .failure(let error):
                print("Failed to upload test FAQ data: \(error)")
            }
        }
    }

    
    // MARK: - Action
    
    @objc func quickReplyTapped(_ sender: UIButton) {
        guard let message = sender.titleLabel?.text else { return }
        sendMessage(message: message)
        
        quickReplyButtons.forEach { $0.isHidden = true }
    }

    
    @objc func sendMessage(message: String) {
        // 快速回覆
        appendMessageAndReload(message)
        
        if let faqData = loadFAQData(), let response = searchFAQ(for: message, in: faqData) {
            self.appendMessageAndReload(response)
        } else {
            // 超出 faq 題庫範圍時 call API
            ChatBotManager.shared.sendChatMessage(message: message) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        self?.appendMessageAndReload("\(response)")
                    case .failure(let error):
                        self?.messages.append("Error: \(error.localizedDescription)")
                        self?.appendMessageAndReload("Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func downloadFAQs(){
        if let localFAQData = loadFAQData() {
                FirestoreService.shared.fetchFAQCategory { [weak self] result in
                    switch result {
                    case .success(let cloudFAQData):
                        if localFAQData.id != cloudFAQData.id {
                            // 本地資料和雲端資料不一致,更新本地資料
                            self?.saveFAQData(cloudFAQData)
                        }
                    case .failure(let error):
                        if let firestoreError = error as? FirestoreError, firestoreError == .noData {
                            // 雲端沒有資料,上傳本地資料到雲端
                            FirestoreService.shared.uploadFAQCategory(localFAQData) { result in
                                switch result {
                                case .success:
                                    print("Successfully uploaded FAQ data")
                                case .failure(let error):
                                    print("Failed to upload FAQ data: \(error)")
                                }
                            }
                        } else {
                            print("Failed to fetch FAQ data: \(error)")
                        }
                    }
                }
            }
    }
    
    func loadFAQData() -> FAQCategory? {
        if let url = Bundle.main.url(forResource: "petsfaq", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let faqCategory = try decoder.decode(FAQCategory.self, from: data)
                return faqCategory
            } catch {
                print("Failed to load FAQ data: \(error)")
            }
        }
        return nil
    }

    func saveFAQData(_ faqCategory: FAQCategory) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(faqCategory),
           let url = getDocumentsDirectory()?.appendingPathComponent("petsfaq.json") {
            do {
                try data.write(to: url)
                print("Successfully saved FAQ data")
            } catch {
                print("Failed to save FAQ data: \(error)")
            }
        }
    }

    func getDocumentsDirectory() -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first
    }


    func searchFAQ(for question: String, in data: FAQCategory) -> String? {
        // 關鍵字分割
        let keywords = question.components(separatedBy: " ")
        let categories = [data.health, data.nutrition, data.care]

        for category in categories {
            for entry in category {
                let entryKeywords = entry.question.components(separatedBy: " ")
                if keywords.contains(where: { entryKeywords.contains($0.lowercased()) }) {
                    return entry.answer
                }
            }
        }
        return nil
    }
    
    func appendMessageAndReload(_ message: String) {
        messages.append(message)
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    @objc func sendButtonTapped() {
        // 使用者輸入訊息
        guard let text = textField.text, !text.isEmpty else { return }
        sendMessage(message: text)
        textField.text = ""
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageBubbleTableViewCell", for: indexPath) as! MessageBubbleTableViewCell
        let message = messages[indexPath.row]
        // 偶數行是 user 的對話
        cell.configure(with: message, isFromCurrentUser: indexPath.row % 2 == 0)
        cell.selectionStyle = .none
        return cell
    }

}
