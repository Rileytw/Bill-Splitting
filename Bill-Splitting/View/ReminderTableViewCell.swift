//
//  ReminderTableViewCell.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/22.
//

import UIKit

class ReminderTableViewCell: UITableViewCell {

    @IBOutlet var memberLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var groupLabel: UILabel!
    @IBOutlet var remindTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func createReminderCell(member: String, type: Int, groupName: String, time: Double) {
        memberLabel.text = "提醒對象：" + "\(member)"
        if type == RemindType.credit.intData {
            typeLabel.text = RemindType.credit.textInfo
            typeLabel.textColor = .systemTeal
        } else {
            typeLabel.text = RemindType.debt.textInfo
            typeLabel.textColor = .systemOrange
        }
        groupLabel.text = "群組：" + groupName
        
        let date = Date(timeIntervalSince1970: time)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let remindDate = dateFormatter.string(from: date)
        remindTime.text = "提醒時間" + remindDate
        
        if time - Date().timeIntervalSince1970 < 0{
            remindTime.textColor = .systemGray
        }
    }
}
