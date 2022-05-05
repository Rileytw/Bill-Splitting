//
//  GroupObject.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/11.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct GroupData: Codable {
    var groupId: String
    var groupName: String
    var groupDescription: String?
    var creator: String
    var type: Int
    var status: Int
    var member: [String]
    var createdTime: Double
    var leaveMembers: [String]?
}

struct MemberExpense: Codable {
    var userId: String
    var allExpense: Double
}

enum GroupType {
    case personal
    case multipleUsers
    
    var typeInt: Int {
        switch self {
        case .personal:
            return 0
        case .multipleUsers:
            return 1
        }
    }
    
    var typeName: String {
        switch self {
        case .personal:
            return "個人預付"
        case .multipleUsers:
            return "多人支付"
        }
    }
}

enum GroupStatus {
    case active
    case inActive
    
    var typeInt: Int {
        switch self {
        case .active:
            return 0
        case .inActive:
            return 1
        }
    }
}
