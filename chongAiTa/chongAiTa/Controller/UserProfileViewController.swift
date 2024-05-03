//
//  UserProfileViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/5/3.
//

import UIKit

class UserProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UserProfileCollectionViewCellDelegate {

    var collectionView: UICollectionView!
    var sections: [ProfileSection] = [
        .about([.userDetails]),
        .account([.logout, .deleteAccount])
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    func setupCollectionView() {
       
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: view.frame.width - 20, height: 100)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.white
        collectionView.register(UserProfileCollectionViewCell.self, forCellWithReuseIdentifier: "UserProfileCollectionViewCell")
        collectionView.register(UserProfileHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UserProfileHeaderReusableView.reuseIdentifier)
        
        layout.headerReferenceSize = CGSize(width: collectionView.bounds.width, height: 50)
        
        view.addSubview(collectionView)
       
    }

    
    // MARK: - CollectionView Delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .about:
            return 1
        case .account(let actions):
            return actions.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserProfileCollectionViewCell", for: indexPath) as! UserProfileCollectionViewCell
        cell.delegate = self

        switch sections[indexPath.section] {
        case .about:
            cell.configure(with: UIImage(systemName: "person.fill"), title: "使用者資料")
        case .account(let actions):
            let action = actions[indexPath.item]
            let title = (action == .logout) ? "登出" : "刪除帳號"
            cell.configure(with: UIImage(systemName: "gear"), title: title)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: UserProfileHeaderReusableView.reuseIdentifier, for: indexPath) as! UserProfileHeaderReusableView
        switch sections[indexPath.section] {
        case .about:
            header.titleLabel.text = "關於"
        case .account:
            header.titleLabel.text = "帳號"
        default:
            header.titleLabel.text = "其他"
        }
        return header
    }

    
    func didTapButton(in cell: UserProfileCollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            switch sections[indexPath.section] {
            case .account(let actions):
                let action = actions[indexPath.item]
                switch action {
                case .logout:
                    print("點擊 登出 按鈕")
                case .deleteAccount:
                    print("點擊 刪除帳號 按鈕")
                default:
                    break
                }
            default:
                break
            }
        }
    }
    
}
