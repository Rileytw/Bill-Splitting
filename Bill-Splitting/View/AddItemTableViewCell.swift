//
//  AddItemTableViewCell.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/14.
//

import UIKit

class AddItemTableViewCell: UITableViewCell {

    @IBOutlet var memberName: UILabel!
    @IBOutlet var selectedButton: UIButton!
    @IBOutlet var priceTextField: UITextField! {
        didSet {
            priceTextField.delegate = self
        }
    }
    
    @IBOutlet var percentLabel: UILabel!
    @IBOutlet var equalLabel: UILabel!
    
    weak var delegate: AddItemTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedButton.setImage(UIImage(systemName: "circle"), for: .normal)
        selectedButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        priceTextField.isHidden = true
        percentLabel.isHidden = true
        equalLabel.isHidden = true
        self.backgroundColor = .clear
        memberName.textColor = UIColor.greenWhite
        selectedButton.tintColor = UIColor.greenWhite
        selectedButton.isUserInteractionEnabled = false
        percentLabel.textColor = UIColor.greenWhite
        equalLabel.textColor = UIColor.greenWhite
        priceTextField.textColor = UIColor.greenWhite
        ElementsStyle.styleTextField(priceTextField)
        
        priceTextField.keyboardType = .numberPad
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func createEqualType(selectedType: InvolvedSelected, selectedNumber: Int?) {
        priceTextField.isHidden = true
        switch selectedType {
        case .selected:
            selectedButton.isSelected = true
            equalLabel.isHidden = false
            percentLabel.text = "%"
            percentLabel.isHidden = false
            
            let percent: Double = (100.00 / Double(selectedNumber ?? 0))
            equalLabel.text = Double.formatString(percent)
        case .unselected:
            selectedButton.isSelected = false
            equalLabel.isHidden = true
            percentLabel.isHidden = true
        }
    }
    
    func createPercentType(selectedType: InvolvedSelected) {
        equalLabel.isHidden = true
        switch selectedType {
        case .selected:
            selectedButton.isSelected = true
            priceTextField.isHidden = false
            percentLabel.text = "%"
            percentLabel.isHidden = false
        case .unselected:
            selectedButton.isSelected = false
            priceTextField.isHidden = true
            percentLabel.isHidden = true
        }
    }
   
    func createCustomizeType(selectedType: InvolvedSelected) {
        equalLabel.isHidden = true
        switch selectedType {
        case .selected:
            selectedButton.isSelected = true
            priceTextField.isHidden = false
            percentLabel.text = "元"
            percentLabel.isHidden = false
        case .unselected:
            selectedButton.isSelected = false
            priceTextField.isHidden = true
            percentLabel.isHidden = true
        }
    }
}

extension AddItemTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.endEditing(self)
    }
}

protocol AddItemTableViewCellDelegate: AnyObject {
    func endEditing(_ cell: AddItemTableViewCell)
}

enum InvolvedSelected {
    case selected
    case unselected
}
