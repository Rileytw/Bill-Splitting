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
    @IBOutlet weak var groupIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let margins = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        contentView.frame = contentView.frame.inset(by: margins)
        super.layoutSubviews()
        
        ElementsStyle.styleView(cellView)
        groupName.textColor = UIColor.greenWhite
        groupType.textColor = UIColor.greenWhite
        numberOfMembers.textColor = UIColor.greenWhite
        self.selectionStyle = UITableViewCell.SelectionStyle.none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setIcon(style: Int) {
        if style == 0 {
            groupIcon.image = UIImage(named: "profile")
        } else if style == 1 {
            groupIcon.image = UIImage(named: "people")
        }
    }
    
}
