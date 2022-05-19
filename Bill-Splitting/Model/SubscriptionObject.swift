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
    var cycle: Cycle
    var subscriptionMember: [SubscriptionMember]?
}

struct SubscriptionMember: Codable {
    var documentId: String
    var involvedUser: String
    var involvedPrice: Double
}

enum Cycle: Int, Codable {
    case month = 0
    case year = 1

    var typeName: String {
        switch self {
        case .month:
            return "每月"
        case .year:
            return "每年"
        }
    }
}
