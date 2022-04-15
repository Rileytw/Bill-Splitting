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
}

struct ExpenseInfo: Codable {
    var userId: String
    var price: Double
}
