//
//  ChatBotViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/18.
//

import UIKit

class ChatBotViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var tableView: UITableView!
    var textField: UITextField!
    var sendButton: UIButton!
    var quickReplyButtons: [UIButton] = []
    
    var messages: [String] = []
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        configureTableView()
        configureQuickReplyButtons()
        
        tableView.register(MessageBubbleTableViewCell.self, forCellReuseIdentifier: "MessageBubbleTableViewCell")
    }
    
    func configureQuickReplyButtons() {
        let messages = ["狗為什麼不吃飼料？", "多久要帶狗去打疫苗？", "狗可以吃巧克力嗎?"]
        
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
        // 聊天列表預設快速回覆
        appendMessageAndReload(message)
        
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
        return cell
    }
    
}
