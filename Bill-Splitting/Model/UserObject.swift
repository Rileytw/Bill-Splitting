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
    var appleId: String?
    var userId: String
    var userName: String
    var userEmail: String
    var group: [String]?
    var payment: [Payment]?
    
    init(appleId: String?, userId: String, userName: String, userEmail: String, group: [String]?, payment: [Payment]?) {
        self.userId = userId
        self.userEmail = userEmail
        self.userName = userName
        self.appleId = appleId
        self.group = group
        self.payment = payment
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
