//
//  ButtonModel.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/24.
//

import Foundation
import UIKit
import SwiftUI

struct ButtonModel {
    let title: String
}

enum GroupButton {
    case allGroups
    case multipleUsers
    case personal
    case close
    
    var buttonName: String {
        switch self {
        case .allGroups:
            return "所有群組"
        case .multipleUsers:
            return "多人支付"
        case .personal:
            return "個人預付"
        case .close:
            return "封存群組"
        }
    }
}
