//
//  ProfileCollectionViewCell.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/2.
//

import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {

    @IBOutlet var icon: UIImageView!
    @IBOutlet var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .selectedColor
        textLabel.textColor = .greenWhite
        icon.tintColor = .greenWhite
    }
    
    func createProfileCell(image: UIImage, text: String) {
        icon.image = image
        textLabel.text = text
    }

}
