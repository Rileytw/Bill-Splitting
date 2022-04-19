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
    var startTime: Double
    var endTime: Double
    var itemName: String
    var paidUser: String
    var paidPrice: Double
    var cycle: Int
}

struct SubscriptionMember: Codable {
    var documentId: String
    var involvedUser: String
    var involvedPrice: Double
}
