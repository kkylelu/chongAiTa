//
//  CustomFunc.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/30.
//

import UIKit

class CustomFunc {
    
    static func customAlert(title: String, message: String, vc: UIViewController, actionHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default) { _ in
            if let actionHandler = actionHandler {
                actionHandler()
            }
        }
        alert.addAction(okAction)
        vc.present(alert, animated: true, completion: nil)
    }
    
}
