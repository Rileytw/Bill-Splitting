//
//  ItermObject.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/13.
//

import Foundation

struct ItemData: Codable {
    var groupId: String
    var itermName: String
    var itermId: String
    var itermDescription: String?
    var createdTime: Double
}

struct ExpenseInfo: Codable {
    var userId: String
    var price: Double
}
