//
//  SettleUpTableViewCell.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/16.
//

import UIKit

class SettleUpTableViewCell: UITableViewCell {

    @IBOutlet var payerName: UILabel!
    @IBOutlet var creditorName: UILabel!
    @IBOutlet var price: UILabel!
    
    @IBOutlet weak var paidLabel: UILabel!
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        payerName.textColor = UIColor.greenWhite
        creditorName.textColor = UIColor.greenWhite
        price.textColor = UIColor.greenWhite
        
        paidLabel.textColor = .greenWhite
        creditLabel.textColor = .greenWhite
        priceLabel.textColor = .greenWhite
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
                contentView.backgroundColor = UIColor.selectedColor
            } else {
                contentView.backgroundColor = UIColor.clear
            }
    }
    
}
