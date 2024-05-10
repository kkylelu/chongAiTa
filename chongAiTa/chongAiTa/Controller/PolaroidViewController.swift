//
//  PolaroidViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/5/10.
//

import UIKit
import CoreMotion

class PolaroidViewController: UIViewController {
    
    private var imageView: UIImageView!
    private var maskView: UIView!
    private var motionManager: CMMotionManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupMotionManager()
    }
    
    private func setupView() {
        // 設置背景顏色
        view.backgroundColor = UIColor.white
        
        // 設置 imageView
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "dogInPark")
        view.addSubview(imageView)
        
        // 設置約束
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 300),
            imageView.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        // 設置 maskView
        maskView = UIView()
        maskView.backgroundColor = UIColor.white
        maskView.alpha = 0.8
        imageView.addSubview(maskView)
        
        // 設置約束
        maskView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            maskView.topAnchor.constraint(equalTo: imageView.topAnchor),
            maskView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            maskView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            maskView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor)
        ])
        
        // 設置拍立得樣式
        imageView.layer.borderColor = UIColor(red: 240/255, green: 234/255, blue: 214/255, alpha: 1.0).cgColor
        imageView.layer.borderWidth = 10
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.5
        imageView.layer.shadowOffset = CGSize(width: 5, height: 5)
        imageView.layer.shadowRadius = 5
        imageView.layer.cornerRadius = 10
    }
    
    private func setupMotionManager() {
        motionManager = CMMotionManager()
        motionManager.accelerometerUpdateInterval = 0.2
        
        if motionManager.isAccelerometerAvailable {
            motionManager.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] (data, error) in
                guard let self = self, let data = data else { return }
                
                let acceleration = data.acceleration
                let threshold: Double = 2.0
                
                if fabs(acceleration.x) > threshold || fabs(acceleration.y) > threshold || fabs(acceleration.z) > threshold {
                    self.revealPhoto()
                }
            }
        }
    }
    
    private func revealPhoto() {
        UIView.animate(withDuration: 2.0) {
            self.maskView.alpha = 0.0
        }
    }
}

