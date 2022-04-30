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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
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
        paidUser.text = "付款人：" + paidMember
        itemDescription.text = description
        itemImage.getImage(image, placeHolder: nil)
    }
}
