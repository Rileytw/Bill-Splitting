//
//  ReportObject.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/5.
//

import Foundation

struct Report: Codable {
    var groupId: String
    var itemId: String
    var reportContent: String?
}
