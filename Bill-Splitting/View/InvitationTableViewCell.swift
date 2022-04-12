//
//  InvitationTableViewCell.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/12.
//

import UIKit

class InvitationTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var agreeButton: UIButton!
    @IBOutlet var disagreeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        agreeButton.setTitle("同意", for: .normal)
        disagreeButton.setTitle("拒絕", for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
