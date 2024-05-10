//
//  PolaroidViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/5/10.
//

import UIKit
import CoreMotion

class PolaroidViewController: UIViewController {
    
    var imageView: UIImageView!
    var maskView: UIView!
    var motionManager: CMMotionManager!
    var journalsArray: [Journal] = []
    var motionLabel: UILabel!
    var getSummaryButton: UIButton!
    let polaroidContainerView = UIView()
    let polaroidBottomView = UIView()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupMotionManager()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupPolaroidStyle()
    }
    
    // MARK: Setup UI
    func setupView() {
        applyDynamicBackgroundColor(lightModeColor: .white, darkModeColor: .black)
        
        polaroidContainerView.translatesAutoresizingMaskIntoConstraints = false
        polaroidContainerView.backgroundColor = .white
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "dogInPark")
        
        maskView = UIView()
        maskView.backgroundColor = UIColor.white
        maskView.alpha = 0.95
        
        polaroidBottomView.backgroundColor = UIColor.white
        
        motionLabel = UILabel()
        motionLabel.text = "👋🏻請搖晃手機顯示照片"
        motionLabel.font = UIFont.systemFont(ofSize: 18)
        
        getSummaryButton = UIButton(type: .system)
        getSummaryButton.setTitle("日記回顧", for: .normal)
        getSummaryButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        getSummaryButton.backgroundColor = UIColor.B1
        getSummaryButton.layer.cornerRadius = 10
        getSummaryButton.tintColor = .white
        getSummaryButton.addTarget(self, action: #selector(generateSummary), for: .touchUpInside)
        
        view.addSubview(polaroidContainerView)
        polaroidContainerView.addSubview(imageView)
        polaroidContainerView.addSubview(maskView)
        polaroidContainerView.addSubview(polaroidBottomView)
        view.addSubview(getSummaryButton)
        view.addSubview(motionLabel)
        
        polaroidContainerView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        maskView.translatesAutoresizingMaskIntoConstraints = false
        getSummaryButton.translatesAutoresizingMaskIntoConstraints = false
        motionLabel.translatesAutoresizingMaskIntoConstraints = false
        polaroidBottomView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            polaroidContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            polaroidContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            polaroidContainerView.widthAnchor.constraint(equalToConstant: 300),
            polaroidContainerView.heightAnchor.constraint(equalToConstant: 400),
            
            imageView.topAnchor.constraint(equalTo: polaroidContainerView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: polaroidContainerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: polaroidContainerView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 350),
            
            maskView.topAnchor.constraint(equalTo: imageView.topAnchor),
            maskView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            maskView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            maskView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            
            polaroidBottomView.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            polaroidBottomView.leadingAnchor.constraint(equalTo: polaroidContainerView.leadingAnchor),
            polaroidBottomView.trailingAnchor.constraint(equalTo: polaroidContainerView.trailingAnchor),
            polaroidBottomView.bottomAnchor.constraint(equalTo: polaroidContainerView.bottomAnchor, constant: 50),
            
            motionLabel.topAnchor.constraint(equalTo: polaroidBottomView.bottomAnchor, constant: 20),
            motionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            getSummaryButton.topAnchor.constraint(equalTo: motionLabel.bottomAnchor, constant: 30),
            getSummaryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            getSummaryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            getSummaryButton.heightAnchor.constraint(equalToConstant: 50)
            
        ])
    }
    
    func setupPolaroidStyle() {
        polaroidContainerView.layer.borderColor = UIColor.white.cgColor
        polaroidContainerView.layer.borderWidth = 10
        polaroidContainerView.layer.shadowColor = UIColor.black.cgColor
        polaroidContainerView.layer.shadowOpacity = 0.3
        polaroidContainerView.layer.shadowOffset = CGSize(width: 5, height: 5)
        polaroidContainerView.layer.shadowRadius = 10
        
    }
    
    func setupMotionManager() {
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
    
    // MARK: - Action
    func revealPhoto() {
        UIView.animate(withDuration: 2.0) {
            self.maskView.alpha = 0.0
        }
    }
    
    // AI 日記回顧
    @objc func generateSummary() {
        navigationItem.leftBarButtonItem?.isEnabled = false
        
        // 延遲 1 秒後重新啟用按鈕，避免連續點擊
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.navigationItem.leftBarButtonItem?.isEnabled = true
        }
        
        // 檢查日記內容是否超過 50 個中文字
        let totalChineseCharacters = journalsArray.reduce(0) { count, journal in
            return count + journal.body.count
        }
        
        if totalChineseCharacters >= 50 {
            view.showLoadingAnimation()
            TextGenerationManager.shared.generateSummary(from: journalsArray) { [weak self] result in
                DispatchQueue.main.async {
                    self?.view.hideLoadingAnimation()
                    switch result {
                    case .success(let summary):
                        self?.displaySummaryAlert(summary)
                    case .failure(let error):
                        print("Error generating summary: \(error)")
                    }
                }
            }
        } else {
            // 顯示提示訊息
            let alert = UIAlertController(title: "缺少日記內容", message: "日記內容需要超過 50 個中文字，才能使用 AI 回顧功能哦🐾", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    func displaySummaryAlert(_ summary: String) {
        let customAlert = CustomAlertView()
        customAlert.configureWith(summary: summary)
        customAlert.show(in: self)
    }
}

