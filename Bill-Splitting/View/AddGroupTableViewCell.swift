//
//  AddGroupTableViewCell.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/11.
//

import UIKit

class AddGroupTableViewCell: UITableViewCell {
    
    @IBOutlet var friendNameLabel: UILabel!
    @IBOutlet var selectedButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
