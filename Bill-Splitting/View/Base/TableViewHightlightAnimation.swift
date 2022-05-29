//
//  TableViewHightlightAnimation.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/24.
//

import UIKit

class TableViewAnimation {
    static func hightlight(cell: UITableViewCell?) {
        UIView.animate(withDuration: 0.25) {
            cell?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
    
    static func unHightlight(cell: UITableViewCell?) {
        UIView.animate(withDuration: 0.25) {
            cell?.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
}
