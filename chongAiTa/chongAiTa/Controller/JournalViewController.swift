//
//  JournalViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/11.
//

import UIKit

class JournalViewController: UIViewController {

    let textView = UITextView()
    let buttonContainerView = UIView()
    let imageButton = UIButton(type: .system)
    let templateButton = UIButton(type: .system)
    let suggestionsButton = UIButton(type: .system)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    //MARK: - Setup UI
    
    func setupUI() {
        
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        
        imageButton.setImage(UIImage(systemName: "photo"), for: .normal)
        templateButton.setImage(UIImage(systemName: "doc"), for: .normal)
        suggestionsButton.setImage(UIImage(systemName: "lightbulb"), for: .normal)
        
        //            imageButton.addTarget(self, action: #selector(didTapImageButton), for: .touchUpInside)
        //            templateButton.addTarget(self, action: #selector(didTapTemplateButton), for: .touchUpInside)
        //            suggestionsButton.addTarget(self, action: #selector(didTapSuggestionsButton), for: .touchUpInside)
        
        // 設定 containerView
        let buttons = [imageButton, templateButton, suggestionsButton]
        for button in buttons {
            buttonContainerView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
        }
        buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonContainerView)
        
        setupConstraints()
    
    }
    
    func setupConstraints() {

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leftAnchor.constraint(equalTo: view.leftAnchor),
            textView.rightAnchor.constraint(equalTo: view.rightAnchor),
            textView.bottomAnchor.constraint(equalTo: buttonContainerView.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            buttonContainerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            buttonContainerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            buttonContainerView.heightAnchor.constraint(equalToConstant: 60),
            buttonContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            imageButton.leftAnchor.constraint(equalTo: buttonContainerView.leftAnchor),
            imageButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor),
            imageButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor),
            imageButton.widthAnchor.constraint(equalTo: buttonContainerView.widthAnchor, multiplier: 1/3)
        ])

        NSLayoutConstraint.activate([
            templateButton.leftAnchor.constraint(equalTo: imageButton.rightAnchor),
            templateButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor),
            templateButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor),
            templateButton.widthAnchor.constraint(equalTo: buttonContainerView.widthAnchor, multiplier: 1/3)
        ])

        NSLayoutConstraint.activate([
            suggestionsButton.leftAnchor.constraint(equalTo: templateButton.rightAnchor),
            suggestionsButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor),
            suggestionsButton.rightAnchor.constraint(equalTo: buttonContainerView.rightAnchor),
            suggestionsButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor),
            suggestionsButton.widthAnchor.constraint(equalTo: buttonContainerView.widthAnchor, multiplier: 1/3)
        ])
    }

    
}
