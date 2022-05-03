//
//  ProfileTableViewCell.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/12.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet var profileItemName: UILabel!
    @IBOutlet var email: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        profileItemName.textColor = .greenWhite
        email.textColor = .greenWhite
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func createCell(userName: String, userEmail: String) {
        profileItemName.text = userName
        email.text = userEmail
    }
}
