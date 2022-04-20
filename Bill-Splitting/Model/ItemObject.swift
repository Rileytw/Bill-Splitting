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
}

struct ExpenseInfo: Codable {
    var userId: String
    var price: Double
    var createdTime: Double?
    var itemId: String?
}

enum SplitType {
    case equal
    case percent
    case customize
    
    var lable: String {
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
