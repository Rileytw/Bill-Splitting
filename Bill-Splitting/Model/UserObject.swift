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
//    var currentUserName: String
}
