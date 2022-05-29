//
//  UserObject.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/11.
//

import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore

struct UserData: Codable {
    var userId: String
    var userName: String
    var userEmail: String
    var group: [String]?
    var payment: [Payment]?
    var blackList: [String]?
    var friends: [Friend]?
    
    init() {
        userId = ""
        userName = ""
        userEmail = ""
        group = nil
        payment = nil
        blackList = nil
        friends = nil
    }
}

struct Payment: Codable {
    var paymentName: String?
    var paymentAccount: String?
    var paymentLink: String?
}

struct Friend: Codable, Equatable {
    var userId: String
    var userName: String
    var userEmail: String
}

struct Invitation: Codable {
    var documentId: String
    var receiverId: String
    var senderId: String
}

struct CurrentUser {
    var currentUserId: String
    var currentUserEmail: String
}

struct FriendSearchModel {
    var friendList: Friend
    var isSelected: Bool
}
