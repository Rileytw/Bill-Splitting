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
        textLabel.textColor = .greenWhite
        icon.tintColor = .greenWhite
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.hexStringToUIColor(hex: "5EB1BF").cgColor
        self.layer.cornerRadius = 20
        self.backgroundColor = UIColor(red: 227/255, green: 246/255, blue: 245/255, alpha: 0.5)
    }
    
    func createProfileCell(image: UIImage, text: String) {
        icon.image = image
        textLabel.text = text
    }

}
