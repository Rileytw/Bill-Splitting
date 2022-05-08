//
//  ReminderTableViewCell.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/22.
//

import UIKit
import SwiftUI

class ReminderTableViewCell: UITableViewCell {
    
    @IBOutlet var memberLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var groupLabel: UILabel!
    @IBOutlet var remindTime: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        memberLabel.textColor = .greenWhite
        typeLabel.textColor = .greenWhite
        groupLabel.textColor = .greenWhite
        remindTime.textColor = .greenWhite
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        ElementsStyle.styleView(cellView)
//        cellView.backgroundColor = UIColor(red: 142/255, green: 198/255, blue: 197/255, alpha: 0.3)
        setIcon()
    }
    
    func setIcon() {
        let configuration = UIImage.SymbolConfiguration(weight: .light)
        if #available(iOS 15, *) {
            icon.image = UIImage(systemName: "megaphone", withConfiguration: configuration)
        } else {
            icon.image = UIImage(systemName: "bell.circle", withConfiguration: configuration)
        }
        icon.tintColor = .greenWhite
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
        remindTime.text = "提醒時間：" + remindDate
        
        if time - Date().timeIntervalSince1970 < 0 {
            remindTime.textColor = .systemGray
        }
    }
}
