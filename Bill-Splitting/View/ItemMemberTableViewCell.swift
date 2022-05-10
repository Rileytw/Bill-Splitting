//
//  ItemMemberTableViewCell.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/22.
//

import UIKit

class ItemMemberTableViewCell: UITableViewCell {

    @IBOutlet var member: UILabel!
    @IBOutlet var price: UILabel!
    
    @IBOutlet weak var involvedImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        member.textColor = .greenWhite
        price.textColor = .greenWhite
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        
        involvedImage.image = UIImage(named: "profile")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func createItemMamberCell(involedMember: String, involvedPrice: Double) {
        member.text = involedMember
//        price.text = "金額 " + String(involvedPrice) + " 元"
        price.text = "金額 " + String(format: "%.2f", involvedPrice) + " 元"
    }
}
