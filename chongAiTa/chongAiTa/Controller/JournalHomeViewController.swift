//
//  JournalHomeViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/14.
//

import UIKit
import Kingfisher
import Lottie
import FirebaseAuth
import CoreMotion

#if !targetEnvironment(simulator)
import JournalingSuggestions
#endif

class JournalHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView: UITableView!
    var floatingButton: UIButton!
    var journalsArray: [Journal] = []
    var emptyPlaceholderLabel: UILabel!
    var activityIndicator: UIActivityIndicatorView!
    var motionManager: CMMotionManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchJournalsFromFirebase()
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "JournalHomeTableViewCell", bundle: nil), forCellReuseIdentifier: "JournalHomeCell")
        
        view.addSubview(tableView)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "message"), style: .plain, target: self, action: #selector(navigateToChatBot))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "photo.artframe"), style: .plain, target: self, action: #selector(showPolaroid))
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        setupFloatingButton()
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewJournalEntry(_:)), name: .newJournalEntrySaved, object: nil)
        
        setupEmptyPlaceholderLabel()
        setupActivityIndicator()
        setupUI()
        updateUI()
        
        generateFakeDataAndUpdateUI()
    }
    
    // MARK: - Setup UI
    
    func generateFakeDataAndUpdateUI() {
        // 產生 3 篇假日記資料
        journalsArray = FakeDataGenerator.generateFakeJournals(count: 3)
        updateUI()
    }
    
    func setupUI(){
        
        applyDynamicBackgroundColor(lightModeColor: .white, darkModeColor: .black)
        
        tableView.separatorStyle = .none
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
    }
    
    
    func setupActivityIndicator(){
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func setupFloatingButton(){
        floatingButton = UIButton(type: .custom)
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        floatingButton.backgroundColor = UIColor.B1
        
        let image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium))?.withRenderingMode(.alwaysTemplate)
        
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
        // 提供觸覺回饋
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator.prepare()
        impactFeedbackGenerator.impactOccurred()
        
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
    
    func updateUI() {
        emptyPlaceholderLabel.isHidden = !journalsArray.isEmpty
        tableView.isHidden = journalsArray.isEmpty
        tableView.reloadData()
    }
    
    
    // MARK: - Action
    
    @objc func showPolaroid() {
            let polaroidVC = PolaroidViewController()
            navigationController?.pushViewController(polaroidVC, animated: true)
        }
    
    @objc func handleNewJournalEntry(_ notification: Notification) {
        if let newJournal = notification.userInfo?["journal"] as? Journal {
            if let index = journalsArray.firstIndex(where: { $0.id == newJournal.id }) {
                journalsArray[index] = newJournal
            } else {
                journalsArray.append(newJournal)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.updateUI()
            }
        }
    }
    
    func fetchJournalsFromFirebase() {
        if let currentUser = Auth.auth().currentUser {
            let userId = currentUser.uid
            
            FirestoreService.shared.fetchJournals(userId: userId) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let journals):
                        // 加入假資料和從 Firebase 下載資料
                        self?.journalsArray = journals + FakeDataGenerator.generateFakeJournals(count: 2)
                        
                        // 依照日期從新到舊排序
                        self?.journalsArray.sort { $0.date > $1.date }
                        
                        self?.updateUI()
                    case .failure(let error):
                        print("Failed to fetch journals from Firebase: \(error)")
                        // 當從 Firebase 下載失敗時,還是可以顯示假資料
                        self?.journalsArray = FakeDataGenerator.generateFakeJournals(count: 2)
                        self?.updateUI()
                    }
                }
            }
        }
    }
    
    // 提供所有日記內容
    func getAllJournals() -> [Journal] {
        return journalsArray
    }
    
    
    @objc func navigateToChatBot() {
        let chatVC = ChatBotViewController()
        navigationController?.pushViewController(chatVC, animated: true)
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
        cell.configure(with: journal)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180.0
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
            
            let journalToDelete = strongSelf.journalsArray[indexPath.row]
            
            if let currentUser = Auth.auth().currentUser {
                let userId = currentUser.uid
            // 從 Firestore 和 Firebase Storage 刪除日記資料和相關圖片
                FirestoreService.shared.deleteJournal(userId: userId, journal: journalToDelete) { result in
                    switch result {
                    case .success:
                        // 刪除資料
                        strongSelf.journalsArray.remove(at: indexPath.row)
                        
                        // 從 tableView 中刪除對應的 cell
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        
                        completionHandler(true)
                        strongSelf.updateUI()
                    case .failure(let error):
                        print("Error deleting journal: \(error)")
                        completionHandler(false)
                    }
                }
            }
        }
        
        deleteAction.backgroundColor = UIColor.B4
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}
