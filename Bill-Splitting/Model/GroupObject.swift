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
    var leaveMemberData: [UserData]?
    var memberExpense: [MemberExpense]?
    var memberData: [UserData]?
    
    init() {
        groupId = ""
        groupName = ""
        groupDescription = nil
        creator = ""
        type = 0
        status = 0
        member = []
        createdTime = 0
        leaveMembers = nil
        memberExpense = nil
        memberData = nil
    }
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

enum GroupStatus: Int, Codable { //
    case active = 0
    case inActive = 1
    
    var typeInt: Int {
        switch self {
        case .active:
            return 0
        case .inActive:
            return 1
        }
    }
}
