//
//  ItemDetailTableViewCell.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/22.
//

import UIKit

class ItemDetailTableViewCell: UITableViewCell {

    @IBOutlet var groupName: UILabel!
    @IBOutlet var itemName: UILabel!
    @IBOutlet var createdTime: UILabel!
    @IBOutlet var price: UILabel!
    @IBOutlet var paidUser: UILabel!
    @IBOutlet var itemDescription: UILabel!
    @IBOutlet var itemImage: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var paidLabel: UILabel!
    @IBOutlet weak var involvedLabel: UILabel!
    @IBOutlet weak var paidUserImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        groupName.textColor = .greenWhite
        itemName.textColor = .greenWhite
        createdTime.textColor = .greenWhite
        price.textColor = .greenWhite
        paidUser.textColor = .greenWhite
        itemDescription.textColor = .greenWhite
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        
        involvedLabel.text = "參與者"
        involvedLabel.textColor = .greenWhite
        
        paidLabel.text = "付款者："
        paidLabel.textColor = .greenWhite
        
        itemDescription.text = "備註："
        itemDescription.textColor = .greenWhite
        
        paidUserImage.image = UIImage(named: "profile")

        descriptionTextView.backgroundColor = .clear
        descriptionTextView.isEditable = false
        descriptionTextView.textColor = UIColor.greenWhite
        descriptionTextView.font = UIFont.systemFont(ofSize: 17)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func createDetailCell(group: String, item: String, time: Double,
                          paidPrice: Double, paidMember: String,
                          description: String?, image: String?) {
        groupName.text = group
        itemName.text = item
        
        let date = Date(timeIntervalSince1970: time)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let createdDate = dateFormatter.string(from: date)
        createdTime.text = createdDate
        
        price.text = "金額：" + String(paidPrice)
        paidUser.text = paidMember
        descriptionTextView.text = description
        itemImage.getImage(image, placeHolder: nil)
    }
}
