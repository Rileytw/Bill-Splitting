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
    @IBOutlet weak var cellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        payerName.textColor = UIColor.greenWhite
        creditorName.textColor = UIColor.greenWhite
        price.textColor = UIColor.greenWhite
        
        paidLabel.textColor = .greenWhite
        creditLabel.textColor = .greenWhite
        priceLabel.textColor = .greenWhite
        setCellView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCellView() {
        ElementsStyle.styleView(cellView)
    }
    
}
