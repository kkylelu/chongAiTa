//
//  MainTabBarController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/27.
//

// MainTabBarController.swift

import UIKit
import Lottie

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let navigationController = viewController as? UINavigationController,
           let petDetailVC = navigationController.viewControllers.first as? PetDetailViewController,
           petDetailVC.isPetDataChanged {
            petDetailVC.savePetData()
        }
    }
    
    
}

