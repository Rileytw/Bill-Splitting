//
//  GroupDetailTableViewCell.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/24.
//

import UIKit

class GroupDetailTableViewCell: UITableViewCell {

    @IBOutlet var groupName: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var groupDescription: UILabel!
    @IBOutlet var descriptionContent: UILabel!
    @IBOutlet var groupType: UILabel!
    @IBOutlet var type: UILabel!
    @IBOutlet var groupMember: UILabel!
    @IBOutlet weak var cellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        groupName.text = "群組名稱："
        groupDescription.text = "群組介紹："
        groupType.text = "群組類型："
        groupMember.text = "群組成員"
        self.backgroundColor = .clear
        groupName.textColor = .greenWhite
        groupDescription.textColor = .greenWhite
        groupType.textColor = .greenWhite
        groupMember.textColor = .greenWhite
        name.textColor = .greenWhite
        type.textColor = .greenWhite
        descriptionContent.textColor = .greenWhite
        setCellView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellView() {
        ElementsStyle.styleView(cellView)
    }
    
    func createDetailCell(groupName: String, content: String?, groupType: Int) {
        name.text = groupName
        descriptionContent.text = content
        
        if groupType == 0 {
            type.text = GroupType.personal.typeName
        } else {
            type.text = GroupType.multipleUsers.typeName
        }
    }
}
