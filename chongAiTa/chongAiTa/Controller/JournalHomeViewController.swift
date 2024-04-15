//
//  JournalHomeViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/14.
//

import UIKit

class JournalHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "JournalHomeTableViewCell", bundle: nil), forCellReuseIdentifier: "JournalHomeCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "JournalHomeCell", for: indexPath) as? JournalHomeTableViewCell else {
                return UITableViewCell()
            }
            
            cell.timeLabel.text = "10:15"
            cell.journalTitleLabel.text = "這裡可自由輸入想要呈現的日記標題"
            cell.journalLocationLabel.text = "公園"
            cell.JournalImageView.image = UIImage(named: "Placeholder picture")

            return cell
        }

        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 165.0
        }
    }
