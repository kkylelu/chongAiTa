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
    
    var messages: [String] = []
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        configureTableView()
        
        tableView.register(MessageBubbleTableViewCell.self, forCellReuseIdentifier: "MessageBubbleTableViewCell")
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
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        view.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: textField.topAnchor),
            
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -20),
            
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            sendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    // MARK: - Action
    
    @objc func sendMessage() {
        guard let text = textField.text, !text.isEmpty else { return }
        appendMessageAndReload("\(text)")
        textField.text = ""
        
        ChatBotManager.shared.sendChatMessage(message: text) { [weak self] result in
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
