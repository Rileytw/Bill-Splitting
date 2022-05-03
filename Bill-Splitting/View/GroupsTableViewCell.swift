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
    @IBOutlet var cellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10))
        let margins = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        contentView.frame = contentView.frame.inset(by: margins)
        super.layoutSubviews()
        
        cellView.layer.cornerRadius = 10
//        cellView.backgroundColor = UIColor(red: 229/255, green: 223/255, blue: 223/255, alpha: 0.8)
        cellView.backgroundColor = UIColor(red: 27/255, green: 38/255, blue: 44/255, alpha: 0.5)
//        "1D4D4F"
        groupName.textColor = UIColor.greenWhite
        groupType.textColor = UIColor.greenWhite
        numberOfMembers.textColor = UIColor.greenWhite
        self.selectionStyle = UITableViewCell.SelectionStyle.none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
