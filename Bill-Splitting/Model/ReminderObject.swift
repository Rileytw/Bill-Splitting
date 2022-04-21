//
//  ReminderObject.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/21.
//

import Foundation

struct Reminder: Codable {
    var groupId: String
    var memberId: String
    var creatorId: String
    var type: Int
    var remindTime: Double
}

enum RemindType {
    case credit
    case debt
    
    var intData: Int {
        switch self {
        case .credit:
            return 0
        case .debt:
            return 1
        }
    }
    
    var textInfo: String {
        switch self {
        case .credit:
            return "請款"
        case .debt:
            return "還款"
        }
    }
}
