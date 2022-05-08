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
    @IBOutlet var chooseButton: UIButton!
    @IBOutlet weak var friendImage: UIImageView!
    
//    {
//        didSet {
//            selectedButton.setImage(UIImage(systemName: "squareshape"), for: .normal)
//            selectedButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
//        }
//    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectedButton.setImage(UIImage(systemName: "circle"), for: .normal)
        selectedButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        self.backgroundColor = .clear
        friendNameLabel.textColor = .greenWhite
        selectedButton.tintColor = .selectedColor
        friendImage.image = UIImage(named: "profile")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
