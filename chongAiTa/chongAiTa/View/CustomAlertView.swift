//
//  CustomAlertView.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/29.
//

import UIKit
import Lottie

class CustomAlertView: UIView {
    
    var animationView: LottieAnimationView!
    var messageLabel: UILabel!
    var confirmButton: UIButton!
    var overlayView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        
    }
    
    private func setupView() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
        animationView = LottieAnimationView(name: "GetSummary")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.5
        addSubview(animationView)
        
        messageLabel = UILabel()
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.textColor = .darkGray
        messageLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        addSubview(messageLabel)
        
        confirmButton = UIButton(type: .system)
        confirmButton.setTitle("確定", for: .normal)
        confirmButton.backgroundColor = UIColor.B1
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.layer.cornerRadius = 20
        confirmButton.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
        addSubview(confirmButton)
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            animationView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            animationView.widthAnchor.constraint(equalToConstant: 100),
            animationView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        ])
        
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            confirmButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            confirmButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            confirmButton.widthAnchor.constraint(equalToConstant: 200),
            confirmButton.heightAnchor.constraint(equalToConstant: 40),
            confirmButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupShadow() {
        self.superview?.layer.shadowColor = UIColor.black.cgColor
        self.superview?.layer.shadowOpacity = 0.1
        self.superview?.layer.shadowOffset = CGSize(width: 0, height: -1)
        self.superview?.layer.shadowRadius = 10
        self.superview?.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        self.superview?.layer.masksToBounds = false
    }
    
    func configureWith(summary: String) {
        messageLabel.text = summary
    }
    
    func show(in viewController: UIViewController) {
        overlayView = UIView()
        overlayView?.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlayView?.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(overlayView!)

        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor),
        ])

        let containerView = UIView(frame: .zero)
        containerView.backgroundColor = .clear
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        containerView.layer.shadowRadius = 10
        containerView.layer.cornerRadius = 10

        self.layer.cornerRadius = 10
        self.clipsToBounds = true

        self.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false

        viewController.view.addSubview(containerView)
        containerView.addSubview(self)

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),
            containerView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            self.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            self.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
        ])

        viewController.view.layoutIfNeeded()
        playAnimation()
    }

    @objc private func dismissAlert() {
        overlayView?.removeFromSuperview()
        self.removeFromSuperview()
    }

    
    func playAnimation() {
        animationView.play()
    }
}
