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

    var messages: [String] = ["123"]
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

    }

    //MARK: - Setup UI
    func setupUI() {
            tableView = UITableView()
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "messageCell")
            tableView.dataSource = self
            tableView.delegate = self
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
            if let text = textField.text, !text.isEmpty {
                messages.append(text)
                let indexPath = IndexPath(row: messages.count - 1, section: 0)
                tableView.insertRows(at: [indexPath], with: .automatic)
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                textField.text = ""
            }
        }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return messages.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)
            cell.textLabel?.text = messages[indexPath.row]
            return cell
        }

}
