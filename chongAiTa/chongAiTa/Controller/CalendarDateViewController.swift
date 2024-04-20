//
//  CalendarDateViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/20.
//

import UIKit

class CalendarDateViewController: UIViewController {
   
    var floatingButton: UIButton!
    var selectedDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupFloatingButton()
    }
    
    // MARK: - Setup UI
    
    func setupUI(){
        view.backgroundColor = .white
        
    }
    
    
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
            let dateEventListVC = DateEventListViewController(date: selectedDate)
            navigationController?.pushViewController(dateEventListVC, animated: true)
        }

}
