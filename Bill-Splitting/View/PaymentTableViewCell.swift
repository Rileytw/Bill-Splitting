//
//  PaymentTableViewCell.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/19.
//

import UIKit

class PaymentTableViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet var paymentName: UILabel!
    @IBOutlet var accountTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        paymentName.font = paymentName.font.withSize(18)
        paymentName.textColor = UIColor.greenWhite
        accountTextView.backgroundColor = .clear
        accountTextView.textColor = .greenWhite
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func createPaymentCell(payment: String, accountName: String, link: String) {
        paymentName.text = payment
        let accountString = accountName
        let linkString = link
        let account = NSMutableAttributedString(string: accountString)
        account.addAttribute(NSAttributedString.Key.font,
                           value: UIFont(name: "System Font Regular", size: 20)!,
                          range: NSMakeRange(0, accountName.count))
        account.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.greenWhite, range: NSMakeRange(0, accountName.count))
        if link != "" {
            account.addAttribute(NSAttributedString.Key.link,
                                 value: linkString,
                                 range: NSMakeRange(0, accountName.count))
        }
        accountTextView.isUserInteractionEnabled = true
        accountTextView.isEditable = false
        accountTextView.attributedText = account
    }
}
