//
//  JournalHomeViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/14.
//

import UIKit
import JournalingSuggestions

class JournalHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var floatingButton: UIButton!
    var journalsArray: [Journal] = []
    
    var emptyPlaceholderLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "JournalHomeTableViewCell", bundle: nil), forCellReuseIdentifier: "JournalHomeCell")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "AI 回顧", style: .plain, target: self, action: #selector(generateSummary))
        
        setupFloatingButton()
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewJournalEntry(_:)), name: .newJournalEntrySaved, object: nil)
        
        setupEmptyPlaceholderLabel()
        updateUI()
        
        }
    
    // MARK: - Setup UI
    
    func setupFloatingButton(){
        floatingButton = UIButton(type: .custom)
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        floatingButton.backgroundColor = UIColor.B1
        
        let image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium))
        
        floatingButton.setImage(image, for: .normal)
        floatingButton.tintColor = .white
        floatingButton.layer.cornerRadius = 28
        floatingButton.layer.shadowOpacity = 0.3
        floatingButton.layer.shadowRadius = 4
        floatingButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        floatingButton.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
        
        view.addSubview(floatingButton)
        
        NSLayoutConstraint.activate([
            floatingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
            floatingButton.widthAnchor.constraint(equalToConstant: 56),
            floatingButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
    }
    
    @objc func floatingButtonTapped() {
        let journalVC = JournalViewController()
        navigationController?.pushViewController(journalVC, animated: true)
    }
    
    func setupEmptyPlaceholderLabel() {
            emptyPlaceholderLabel = UILabel()
            emptyPlaceholderLabel.text = "點擊下方「加號圖示➕」新增日記"
            emptyPlaceholderLabel.textColor = UIColor.gray
            emptyPlaceholderLabel.textAlignment = .center
            emptyPlaceholderLabel.font = UIFont.systemFont(ofSize: 20)
            emptyPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(emptyPlaceholderLabel)
            
            NSLayoutConstraint.activate([
                emptyPlaceholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                emptyPlaceholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                emptyPlaceholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                emptyPlaceholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            ])
            
            emptyPlaceholderLabel.isHidden = true
        }
    
    // MARK: - UpdateUI
    
    private func updateUI() {
            emptyPlaceholderLabel.isHidden = !journalsArray.isEmpty
            tableView.isHidden = journalsArray.isEmpty
            tableView.reloadData()
        }
    
    
    // MARK: - Action
    
    @objc func handleNewJournalEntry(_ notification: Notification) {
        if let newJournal = notification.userInfo?["journal"] as? Journal {
            if let index = journalsArray.firstIndex(where: { $0.id == newJournal.id }) {
                journalsArray[index] = newJournal
            } else {
                journalsArray.append(newJournal)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    
    // AI 日記回顧
    @objc func generateSummary() {
        TextGenerationManager.shared.generateSummary(from: journalsArray) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let summary):
                    self?.displaySummaryAlert(summary)
                case .failure(let error):
                    print("Error generating summary: \(error)")
                }
            }
        }
    }
    
    func displaySummaryAlert(_ summary: String) {
        let alert = UIAlertController(title: "AI 日記回顧", message: summary, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "關閉", style: .default))
        self.present(alert, animated: true)
    }
    
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return journalsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "JournalHomeCell", for: indexPath) as? JournalHomeTableViewCell else {
            return UITableViewCell()
        }
        
        let journal = journalsArray[indexPath.row]
            cell.journalTitleLabel.text = journal.title
        
        let previewText = journal.body.prefix(12)
            cell.journalContentLabel.text = String(previewText) + "..."
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh_Hant_TW")
        dateFormatter.dateFormat = "yyyy 年 M 月 d 日 EEEE"
        cell.timeLabel.text = dateFormatter.string(from: journal.date)

        if !journal.images.isEmpty {
            cell.JournalImageView.contentMode = .scaleAspectFill
            cell.JournalImageView.clipsToBounds = true
            cell.JournalImageView.image = journal.images.first
            print("Displaying image for row \(indexPath.row)")
        } else {
            cell.JournalImageView.image = nil
            print("No image to display for row \(indexPath.row)")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 165.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedJournal = journalsArray[indexPath.row]
        let journalVC = JournalViewController()
        journalVC.journal = selectedJournal
        navigationController?.pushViewController(journalVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { [weak self] (action, view, completionHandler) in
            guard let strongSelf = self else {
                completionHandler(false)
                return
            }

            // 刪除資料
            strongSelf.journalsArray.remove(at: indexPath.row)

            // 從 tableView 中刪除對應的 cell
            tableView.deleteRows(at: [indexPath], with: .automatic)

            completionHandler(true)
        }

        deleteAction.backgroundColor = UIColor.B4

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }

    
}
