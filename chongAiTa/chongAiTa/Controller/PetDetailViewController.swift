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
    
    let petImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 75
        return imageView
    }()
    
    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.B1
        view.layer.cornerRadius = 100
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        
        view.addSubview(tableView)
        view.addSubview(backgroundView)
        view.addSubview(petImageView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        petImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: petImageView.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            petImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            petImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            petImageView.widthAnchor.constraint(equalToConstant: 150),
            petImageView.heightAnchor.constraint(equalToConstant: 150),
            
            backgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: petImageView.centerYAnchor, constant:  -200),
            backgroundView.widthAnchor.constraint(equalToConstant: 450),
            backgroundView.heightAnchor.constraint(equalToConstant: 450)
        ])
        
        setupUI()
        loadFakeData()
    }
    
    
    // MARK: - Setup UI
    func setupUI() {
        view.backgroundColor = .white
    }
    
    func loadFakeData() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let fakePet = Pet(photo: "mydog",
                          name: "Buddy",
                          gender: .male,
                          type: .dog,
                          breed: "米克斯",
                          birthday: dateFormatter.date(from: "2018-03-01"),
                          joinDate: dateFormatter.date(from: "2020-05-20"),
                          weight: 15.0,
                          isNeutered: true)
        setPet(fakePet)
    }
    
    func setPet(_ pet: Pet) {
        self.pet = pet
        petImageView.image = UIImage(named: pet.photo ?? "ShibaInuIcon")
        tableView.reloadData()
    }
    
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
        
//        cell.delegate = self
        let item = PetDetailItem.forIndexPath(indexPath)
        if let pet = pet {
            cell.configure(with: item, pet: pet)
        }
        
        return cell
    }

    
    // MARK: - PetDetailTableViewCellDelegate
//    func didTapButton(_ sender: PetDetailTableViewCell) {
//        guard let indexPath = tableView.indexPath(for: sender) else { return }
//        showDetailMenu(for: indexPath)
//    }
    
//    // MARK: - Show Detail Menu
//    func showDetailMenu(for indexPath: IndexPath) {
//        let detailMenuVC = DetailMenuViewController()
//        detailMenuVC.modalPresentationStyle = .overFullScreen
//        detailMenuVC.modalTransitionStyle = .crossDissolve
//        
//        let item = PetDetailItem.forIndexPath(indexPath)
//        detailMenuVC.item = item
//        detailMenuVC.pet = pet
//        
//        present(detailMenuVC, animated: true)
//    }
}
