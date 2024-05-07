//
//  UserProfileViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/5/3.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

// For Sign in with Apple
import AuthenticationServices
import CryptoKit

class UserProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UserProfileCollectionViewCellDelegate {
    
    var collectionView: UICollectionView!
    var sections: [ProfileSection] = [
        .about([.userDetails]),
        .account([.logout, .deleteAccount])
    ]
    var errorMessage = ""
    var user: User?
    var aboutAppView: UIView?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        applyDynamicBackgroundColor(lightModeColor: .white, darkModeColor: .black)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissAboutAppView))
                view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Setup UI
    func setupCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: view.frame.width - 20, height: 100)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UserProfileCollectionViewCell.self, forCellWithReuseIdentifier: "UserProfileCollectionViewCell")
        collectionView.register(UserProfileHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UserProfileHeaderReusableView.reuseIdentifier)
        
        layout.headerReferenceSize = CGSize(width: collectionView.bounds.width, height: 50)
        
        if #available(iOS 13.0, *) {
            collectionView.backgroundColor = UIColor { (traitCollection) -> UIColor in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return .black
                default:
                    return .white
                }
            }
        } else {
            collectionView.backgroundColor = .white
        }
        
        view.addSubview(collectionView)
        
    }
    
    // MARK: - Action
    
    @objc func dismissAboutAppView() {
            aboutAppView?.removeFromSuperview()
            aboutAppView = nil
        }
    
    func didTapButton(in cell: UserProfileCollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            switch sections[indexPath.section] {
            case .about:
                showAboutAppView()
            case .account(let actions):
                let action = actions[indexPath.item]
                switch action {
                case .logout:
                    print("點擊 登出 按鈕")
                    signOut()
                case .deleteAccount:
                    print("點擊 刪除帳號 按鈕")
                    let alert = UIAlertController(title: "確定要刪除帳號嗎？", message: "帳號一旦刪除，將無法復原", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "確定", style: .destructive, handler: { [weak self] _ in
                        guard let strongSelf = self else { return }
                        Task {
                            let success = await strongSelf.deleteAccount()
                            if success {
                                print("帳號已刪除。")
                            } else {
                                print("刪除帳號失敗")
                            }
                        }
                    }))
                    if let viewController = collectionView.window?.rootViewController {
                        viewController.present(alert, animated: true, completion: nil)
                    }
                default:
                    break
                }
            default:
                break
            }
        }
    }
    
    func showAboutAppView() {
        let aboutAppView = UIView(frame: UIScreen.main.bounds)
        aboutAppView.backgroundColor = UIColor.B1
        
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.frame = CGRect(x: 20, y: 50, width: 40, height: 40)
        backButton.addTarget(self, action: #selector(dismissAboutAppView), for: .touchUpInside)
        aboutAppView.addSubview(backButton)
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 128, height: 128))
        imageView.center = CGPoint(x: aboutAppView.center.x, y: aboutAppView.center.y - 63)
        imageView.image = UIImage(named: "pawsPalIcon_pure")
        aboutAppView.addSubview(imageView)
        
        let label = UILabel(frame: CGRect(x: 0, y: imageView.frame.maxY + 10, width: aboutAppView.frame.width, height: 50))
        label.text = "PawsPal"
        label.textColor = .white
        label.font = UIFont(name: "Helvetica Neue Bold", size: 30)
        label.textAlignment = .center
        aboutAppView.addSubview(label)
        
        if let viewController = self.view.window?.rootViewController {
            viewController.view.addSubview(aboutAppView)
            self.aboutAppView = aboutAppView
        }
    }
    
    func signOut(){
        do {
            try Auth.auth().signOut()
            print("使用者成功登出")
        }
        catch {
            print(error)
            errorMessage = error.localizedDescription
        }
        
    }
    
    func deleteAccount() async -> Bool {
        guard let user = Auth.auth().currentUser else {
            print("沒有找到用戶。")
            return false
        }
        guard let lastSignInDate = user.metadata.lastSignInDate else { return false }
        let needsReauth = !lastSignInDate.isWithinPast(minutes: 5)
        
        let needsTokenRevocation = user.providerData.contains { $0.providerID == "apple.com" }
        
        do {
            if needsReauth || needsTokenRevocation {
                let signInWithApple = SignInWithApple()
                let appleIDCredential = try await signInWithApple()
                
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetdch identify token.")
                    return false
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialise token string from data: \(appleIDToken.debugDescription)")
                    return false
                }
                
                let nonce = randomNonceString()
                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)
                
                if needsReauth {
                    try await user.reauthenticate(with: credential)
                }
                if needsTokenRevocation {
                    guard let authorizationCode = appleIDCredential.authorizationCode else { return false }
                    guard let authCodeString = String(data: authorizationCode, encoding: .utf8) else { return false }
                    
                    try await Auth.auth().revokeToken(withAuthorizationCode: authCodeString)
                }
            }
            
            try await user.delete()
            errorMessage = ""
            return true
        }
        catch {
            print(error)
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
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
            cell.configure(with: UIImage(systemName: "pawprint.fill"), title: "關於 PawsPal")
        case .account(let actions):
            let action = actions[indexPath.item]
            switch action {
                    case .logout:
                        cell.configure(with: UIImage(systemName: "arrow.right.square"), title: "登出")
                    case .deleteAccount:
                        cell.configure(with: UIImage(systemName: "trash"), title: "刪除帳號")
                    }
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if #available(iOS 13.0, *) {
            cell.backgroundColor = UIColor { (traitCollection) -> UIColor in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return .black
                default:
                    return .clear
                }
            }
        } else {
            cell.backgroundColor = .clear
        }
    }
    
    
}

class SignInWithApple: NSObject, ASAuthorizationControllerDelegate {
    private var continuation : CheckedContinuation<ASAuthorizationAppleIDCredential, Error>?
    
    func callAsFunction() async throws -> ASAuthorizationAppleIDCredential {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.performRequests()
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if case let appleIDCredential as ASAuthorizationAppleIDCredential = authorization.credential {
            continuation?.resume(returning: appleIDCredential)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
    }
}

extension Date {
    func isWithinPast(minutes: Int) -> Bool {
        let now = Date.now
        let timeAgo = Date.now.addingTimeInterval(-1 * TimeInterval(60 * minutes))
        let range = timeAgo...now
        return range.contains(self)
    }
}
