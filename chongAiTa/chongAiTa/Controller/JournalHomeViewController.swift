//
//  JournalHomeViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/14.
//

import UIKit

class JournalHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var floatingButton: UIButton!
    var journalsArray: [Journal] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "JournalHomeTableViewCell", bundle: nil), forCellReuseIdentifier: "JournalHomeCell")
        
        setupFloatingButton()
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
        journalVC.delegate = self
        navigationController?.pushViewController(journalVC, animated: true)
    }

    
    func showJournalViewController() {
        let journalVC = JournalViewController()
        journalVC.delegate = self
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
        
        let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "zh_Hant_TW")
            dateFormatter.dateFormat = "yyyy 年 M 月 d 日 EEEE"

        cell.timeLabel.text = dateFormatter.string(from: journal.date)
        cell.journalTitleLabel.text = journal.title
        cell.journalLocationLabel.text = journal.location
        
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
    }

extension JournalHomeViewController: JournalViewControllerDelegate {
    func journalEntryDidSave(_ journal: Journal) {
        self.journalsArray.append(journal)
        self.tableView.reloadData()
    }
}
