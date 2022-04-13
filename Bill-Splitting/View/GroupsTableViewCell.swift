//
//  GroupsTableViewCell.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/13.
//

import UIKit

class GroupsTableViewCell: UITableViewCell {

    @IBOutlet var groupName: UILabel!
    @IBOutlet var groupType: UILabel!
    @IBOutlet var numberOfMembers: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
