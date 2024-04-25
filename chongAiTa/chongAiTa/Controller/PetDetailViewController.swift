//
//  PetDetailViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/25.
//

import UIKit

class PetDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var pet: Pet?
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(UINib(nibName: "PetDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "PetDetailTableViewCell")
        return tableView
    }()

    
//    let petImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        return imageView
//    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設置 tableView 的 delegate 和 dataSource
        tableView.delegate = self
        tableView.dataSource = self
        
        // 將 tableView 加入到畫面中
        view.addSubview(tableView)
        
        // 設置 tableView 的 constraints
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
//        configureUI()
//        loadFakeData()
    }

    
    // MARK: Setup UI
//    func loadFakeData() {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        let fakePet = Pet(photo: "buddy",
//                          name: "Buddy",
//                          gender: .male,
//                          type: .dog,
//                          breed: "Labrador",
//                          birthday: dateFormatter.date(from: "2018-03-01"),
//                          joinDate: dateFormatter.date(from: "2020-05-20"),
//                          weight: 15.0,
//                          isNeutered: true)
//        setPet(fakePet)
//    }
    
    
    func setPet(_ pet: Pet) {
        self.pet = pet
//        petImageView.image = UIImage(named: pet.photo ?? "Placeholder picture")
        tableView.reloadData()
    }
    
//    func configureUI() {
//        tableView.dataSource = self
//        tableView.delegate = self
//    
//    }
    
    // MARK: - TableView Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            return 4
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PetDetailTableViewCell.reuseIdentifier, for: indexPath) as? PetDetailTableViewCell else {
            fatalError("Unexpected Table View Cell")
        }
        
        let item = PetDetailItem.forIndexPath(indexPath)
        if let pet = pet {
            cell.configure(with: item, pet: pet)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: 點擊 cell 打開選單
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
