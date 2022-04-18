//
//  SubscriptionObject.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/18.
//

import Foundation

struct Subscription: Codable {
    var doucmentId: String
    var groupId: String
    var createdTime: Double
    var itemName: String
    var paidUser: String
    var paidPrice: Double
}
