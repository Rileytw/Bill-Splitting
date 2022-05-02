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
//    {
//        didSet {
//            selectedButton.setImage(UIImage(systemName: "squareshape"), for: .normal)
//            selectedButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
//        }
//    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectedButton.setImage(UIImage(systemName: "squareshape"), for: .normal)
        selectedButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        self.backgroundColor = .clear
        friendNameLabel.textColor = .greenWhite
        selectedButton.tintColor = .greenWhite
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
