//
//  SubscirbeView.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/17.
//

import UIKit

class SubscirbeView: UIView {

    var datePicker = UIDatePicker()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
 
    override func layoutSubviews() {
        super.layoutSubviews()
        setPickerView()
    }
    
    func setPickerView() {
        datePicker.frame = CGRect(x: 20, y: 20, width: 300, height: 100)
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        } else {
            // Fallback on earlier versions
        }
        datePicker.locale = Locale(identifier: "zh_Hant_TW")
        datePicker.calendar = Calendar(identifier: .republicOfChina)
    }
}
