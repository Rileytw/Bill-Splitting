//
//  ItemObject.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/13.
//

import Foundation

struct ItemData: Codable {
    var groupId: String
    var itemName: String
    var itemId: String
    var itemDescription: String?
    var createdTime: Double
    var itemImage: String?
    var paidInfo: [ExpenseInfo]?
    var involedInfo: [ExpenseInfo]?
    
    init() {
        groupId = ""
        itemId = ""
        itemName = ""
        itemDescription = nil
        createdTime = 0
        itemImage = nil
        paidInfo = nil
        involedInfo = nil
    }
}

struct ExpenseInfo: Codable {
    var userId: String
    var price: Double
    var createdTime: Double?
    var itemId: String?
    
    init() {
        userId = ""
        price = 0
        createdTime = nil
        itemId = nil
    }
}

enum SplitType {
    case equal
    case percent
    case customize
    
    var label: String {
        switch self {
        case .equal:
            return "平分"
        case .percent:
            return "按比例"
        case .customize:
            return "自訂"
        }
    }
    
}
