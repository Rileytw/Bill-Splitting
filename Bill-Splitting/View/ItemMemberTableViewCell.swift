//
//  ItemMemberTableViewCell.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/22.
//

import UIKit

class ItemMemberTableViewCell: UITableViewCell {

    @IBOutlet var type: UILabel!
    @IBOutlet var member: UILabel!
    @IBOutlet var price: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func createItemMamberCell(involedMember: String, involvedPrice: Double) {
        type.text = "參與人"
        member.text = involedMember
        price.text = "金額" + String(involvedPrice)
    }
}
