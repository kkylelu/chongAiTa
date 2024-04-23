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
    
    func downloadFAQs() {
        let db = Firestore.firestore()
        let categories = ["health", "nutrition", "care"]
        var allFAQs: [String: [FAQEntry]] = [:]
        let dispatchGroup = DispatchGroup()

        for category in categories {
            dispatchGroup.enter()
            db.collection("faqs").document("id").collection(category).getDocuments { (snapshot, error) in
                if let error = error {
                    print("下載 \(category) 分類的文件出錯: \(error)")
                } else if let snapshot = snapshot {
                    var categoryFAQs: [FAQEntry] = []
                    for document in snapshot.documents {
                        let question = document.data()["question"] as? String ?? "No question"
                        let answer = document.data()["answer"] as? String ?? "No answer"
                        categoryFAQs.append(FAQEntry(question: question, answer: answer))
                    }
                    allFAQs[category] = categoryFAQs
                    
                    // 確保在所有類別的FAQ都已經讀取之後再更新 local 檔案
                    if allFAQs.keys.count == categories.count {
                        self.updateLocalFAQs(allFAQs)
                    }
                }
                dispatchGroup.notify(queue: .main) {
                        self.updateLocalFAQs(allFAQs)
                    }
            }
        }
    }

    func updateLocalFAQs(_ faqs: [String: [FAQEntry]]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(faqs) {
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let fileURL = urls[0].appendingPathComponent("petsfaq.json")
            do {
                try encoded.write(to: fileURL)
                print("成功更新預設 FAQ")

                // 驗證資料是否被寫入
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                if let decodedFAQs = try? decoder.decode([String: [FAQEntry]].self, from: data) {
                    print("驗證成功，資料已被寫入且可以正確讀取。")
                    print(decodedFAQs)
                } else {
                    print("資料寫入後無法解碼，請檢查資料結構和JSON格式。")
                }
            } catch {
                print("更新預設 FAQ 失敗: \(error)")
            }
        }
    }

    func loadFAQData() -> FAQCategory? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let fileURL = urls[0].appendingPathComponent("petsfaq.json")

        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(FAQCategory.self, from: data)
                return jsonData
            } catch {
                print("Failed to load or parse FAQ data: \(error)")
            }
        } else {
            print("FAQ file does not exist at path: \(fileURL.path)")
        }
        return nil
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
