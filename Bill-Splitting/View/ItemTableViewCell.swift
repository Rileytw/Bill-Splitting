//
//  ItemTableViewCell.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/15.
//

import UIKit
import SwiftUI

enum PaidDescription: String {
    case paid = "你已支付"
    case involved = "你應支付"
    case notInvolved = "你未參與"
    case settleUpPaid = "已收款"
    case settleUpInvolved = "已付款"
}

enum InvolvedType {
    case paid
    case involved
    case notInvolved
}

class ItemTableViewCell: UITableViewCell {

    @IBOutlet var createdTime: UILabel!
    @IBOutlet var itemName: UILabel!
    @IBOutlet var paidDescription: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var colorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        createdTime.textColor = UIColor.greenWhite
        itemName.textColor = UIColor.greenWhite
        priceLabel.textColor = UIColor.greenWhite
        
        ElementsStyle.styleView(cellView)
        colorView.backgroundColor = .styleBlue
        
        self.selectionStyle = UITableViewCell.SelectionStyle.none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func createItemCell(time: String, name: String, description: PaidDescription, price: Double) {
        createdTime.text = time
        itemName.text = name
        paidDescription.text = description.rawValue
        if price != 0 {
            priceLabel.text = "$" + String(format: "%.2f", price)
        } else {
            priceLabel.text = ""
        }
    }
    
    func mapItemCell(item: ItemData,
                     time: String,
                     paidPrice: Double,
                     involvedPrice: Double,
                     involvedType: InvolvedType) {
        switch involvedType {
        case .paid:
            if item.itemName == "結帳" {
                createItemCell(time: time, name: item.itemName,
                               description: PaidDescription.settleUpInvolved, price: paidPrice)
                paidDescription.textColor = .styleRed
            } else {
                createItemCell(time: time, name: item.itemName, description: PaidDescription.paid, price: paidPrice)
                paidDescription.textColor = .styleGreen
            }
        case .involved:
            if item.itemName == "結帳" {
                createItemCell(time: time,
                                         name: item.itemName,
                                         description: PaidDescription.settleUpPaid,
                                         price: involvedPrice)
                paidDescription.textColor = .styleGreen
            } else {
                createItemCell(time: time,
                                         name: item.itemName,
                                         description: PaidDescription.involved,
                                         price: involvedPrice)
                paidDescription.textColor = .styleRed
            }
        case .notInvolved:
            createItemCell(time: time,
                                     name: item.itemName,
                                     description: PaidDescription.notInvolved,
                                     price: 0)
            paidDescription.textColor = .greenWhite
        }
    }
}
