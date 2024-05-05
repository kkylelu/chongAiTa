//
//  AppDelegate.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/10.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import GoogleMaps

@main
class AppDelegate: UIResponder, UIApplicationDelegate { 

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        
        let apiKeys = APIKeys(resourceName: "API-Keys")
        GMSServices.provideAPIKey(apiKeys.googleMapsAPIKey)
        GMSServices.provideAPIKey(apiKeys.googlePlacesAPIKey)
        
        FirebaseApp.configure()
        
        UINavigationBar.appearance().backgroundColor = UIColor.B1
        UINavigationBar.appearance().tintColor = .white
        
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.B1
            appearance.shadowColor = nil

            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        
        UITabBar.appearance().tintColor = UIColor.B1
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

