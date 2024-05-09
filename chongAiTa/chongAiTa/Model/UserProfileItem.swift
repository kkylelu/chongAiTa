//
//  UserProfileItem.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/5/3.
//

import UIKit
enum ProfileSection {
    case about([UserInfo])
    case account([AccountAction])
    case contactDeveloper
}

enum UserInfo {
    case userDetails
}

enum AccountAction {
    case logout
    case deleteAccount
}
