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
    @IBOutlet var email: UILabel!
    
    var delegate: TableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        nameLabel.textColor = .greenWhite
        email.textColor = .greenWhite
        agreeButton.setTitle("同意", for: .normal)
        disagreeButton.setTitle("拒絕", for: .normal)
        agreeButton.tintColor = .greenWhite
        disagreeButton.tintColor = .greenWhite
        ElementsStyle.styleSpecificButton(agreeButton)
        ElementsStyle.styleSpecificButton(disagreeButton)
        agreeButton.layer.cornerRadius = 10
        disagreeButton.layer.cornerRadius = 10
        
        self.agreeButton.addTarget(self, action: #selector(pressAgreeButton), for: .touchUpInside)
        self.disagreeButton.addTarget(self, action: #selector(pressDisagreeButton), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @objc func pressAgreeButton() {
        delegate?.agreeInvitation(sender: self)
    }
    
    @objc func pressDisagreeButton() {
        delegate?.disAgreeInvitation(sender: self)
    }
    
}

protocol TableViewCellDelegate {
    
    func agreeInvitation(sender: InvitationTableViewCell)
    
    func disAgreeInvitation(sender: InvitationTableViewCell)
}
