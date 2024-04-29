//
//  WaitIndicatorFootPrint.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/29.
//

import UIKit
import Lottie

extension UIView {
    private static var loadingAnimationView: LottieAnimationView?
    private static var overlayView: UIView?

    func showLoadingAnimation() {
        if UIView.loadingAnimationView == nil {
            UIView.loadingAnimationView = .init(name: "FootPrint")
            UIView.loadingAnimationView?.contentMode = .scaleAspectFit
            UIView.loadingAnimationView?.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
            UIView.loadingAnimationView?.center = self.center
            UIView.loadingAnimationView?.loopMode = .loop
            UIView.loadingAnimationView?.animationSpeed = 0.5
            UIView.loadingAnimationView?.transform = CGAffineTransform(rotationAngle: .pi / 2)

            UIView.overlayView = UIView(frame: self.bounds)
            UIView.overlayView?.backgroundColor = UIColor.white.withAlphaComponent(0.3)
            UIView.overlayView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }

        if let overlay = UIView.overlayView {
                    self.addSubview(overlay)
                    NSLayoutConstraint.activate([
                        overlay.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
                        overlay.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
                        overlay.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
                        overlay.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
                    ])
                }
        
        self.addSubview(UIView.loadingAnimationView!)
        UIView.loadingAnimationView?.isHidden = false
        UIView.loadingAnimationView?.play()
    }
    
    func hideLoadingAnimation() {
        UIView.loadingAnimationView?.isHidden = true
        UIView.loadingAnimationView?.stop()
        UIView.overlayView?.removeFromSuperview()
    }
}


