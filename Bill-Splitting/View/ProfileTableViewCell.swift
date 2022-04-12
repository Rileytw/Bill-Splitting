//
//  ProfileTableViewCell.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/12.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet var profileItemName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
