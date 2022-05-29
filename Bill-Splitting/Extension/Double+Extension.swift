//
//  Double+Extension.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/19.
//

import UIKit

extension Double {
    static func formatString(_ input: Double) -> String {
        let revealString = String(format: "%.2f", input)
        return revealString
    }
}
