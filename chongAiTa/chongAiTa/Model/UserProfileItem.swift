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
}

enum UserInfo {
    case userDetails
}

enum AccountAction {
    case logout
    case deleteAccount
}
