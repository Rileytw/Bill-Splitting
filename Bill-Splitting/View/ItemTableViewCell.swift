//
//  ItemTableViewCell.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/15.
//

import UIKit

enum PaidDescription: String {
    case paid = "你已支付"
    case involved = "你應支付"
    case notInvolved = "你未參與"
    case settleUpPaid = "已付款"
    case settleUpInvolved = "已收款"
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
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
                contentView.backgroundColor = UIColor.selectedColor
            } else {
                contentView.backgroundColor = UIColor.clear
            }
    }
    
    func createItemCell(time: String, name: String, description: PaidDescription, price: String) {
        createdTime.text = time
        itemName.text = name
        paidDescription.text = description.rawValue
        priceLabel.text = price
    }
    
    func setIcon(style: Int) {

//        if style == 0 {
//            colorView.backgroundColor = .styleGreen
//        } else if style == 1 {
//            colorView.backgroundColor = .styleRed
//        } else {
//            colorView.backgroundColor = .greenWhite
//        }
    }
}
