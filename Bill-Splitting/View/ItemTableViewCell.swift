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
    @IBOutlet weak var icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        createdTime.textColor = UIColor.greenWhite
        itemName.textColor = UIColor.greenWhite
        priceLabel.textColor = UIColor.greenWhite
        
        ElementsStyle.styleView(cellView)
        cellView.backgroundColor = UIColor(red: 142/255, green: 198/255, blue: 197/255, alpha: 0.3)
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
        let configuration = UIImage.SymbolConfiguration(weight: .light)
        if style == 0 {
            icon.image = UIImage(systemName: "increase.indent", withConfiguration: configuration)
        } else if style == 1 {
            icon.image = UIImage(systemName: "decrease.indent", withConfiguration: configuration)
        } else if style == 2 {
            icon.image = UIImage(systemName: "line.horizontal.3.decrease", withConfiguration: configuration)
        } else {
            icon.image = UIImage(systemName: "creditcard", withConfiguration: configuration)
        }
        icon.tintColor = .greenWhite
    }
}
