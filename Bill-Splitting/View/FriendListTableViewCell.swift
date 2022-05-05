//
//  ProfileTableViewCell.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/12.
//

import UIKit

class FriendListTableViewCell: UITableViewCell {

    @IBOutlet var profileItemName: UILabel!
    @IBOutlet var email: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        profileItemName.textColor = .greenWhite
        email.textColor = .greenWhite
        infoButton.tintColor = .greenWhite
        self.selectionStyle = UITableViewCell.SelectionStyle.none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func createCell(userName: String, userEmail: String) {
        profileItemName.text = userName
        email.text = userEmail
    }
}
