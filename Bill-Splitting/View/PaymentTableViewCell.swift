//
//  PaymentTableViewCell.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/19.
//

import UIKit

class PaymentTableViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet var paymentName: UILabel!
    @IBOutlet var account: UILabel!
    @IBOutlet var linkTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func createPaymentCell(payment: String, accountName: String) {
        paymentName.text = payment
        account.text = accountName
        let string = NSMutableAttributedString(string: linkTextView.text)
        let attribute = [ NSMutableAttributedString.Key.font: UIFont(name: "System Font Regular", size: 40)!]
        linkTextView.attributedText = NSMutableAttributedString(string: string.string, attributes: attribute)
    }
}
