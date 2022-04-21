//
//  AddReminderViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/20.
//

import UIKit

class AddReminderViewController: UIViewController {

    let groupLabel = UILabel()
    let groupPicker = BasePickerViewInTextField(frame: .zero)
    let userLabel = UILabel()
    let userPicker = BasePickerViewInTextField(frame: .zero)
    let typeLabel = UILabel()
    let typePicker = BasePickerViewInTextField(frame: .zero)
    let priceLabel = UILabel()
    let priceTextField = UITextField()
    let completeButton = UIButton()
    let debtButton = UIButton()
    let creditButton = UIButton()
//    var groupPickerData = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setGroup()
        setGroupPicker()
        setUser()
        setUserPicker()
        setType()
//        setTypePicker()
        setButtons()
        setCompleteButton()
    }
    
// MARK: Wait to try
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        if #available(iOS 15.0, *) {
//
//        } else {
//            self.view.frame = CGRect(x: 0, y: UIScreen.main.bounds.height / 5 * 2, width: self.view.bounds.width, height: UIScreen.main.bounds.height / 5 * 3)
//            self.view.layer.cornerRadius = 20
//            self.view.layer.masksToBounds = true
//        }
//    }

    func setGroup() {
        view.addSubview(groupLabel)
        setGroupLabelConstraint()
        groupLabel.text = "選擇群組"
    }
    
    func setGroupPicker() {
        view.addSubview(groupPicker)
        setGroupPickerConstraint()
        
    }
    
    func setUser() {
        view.addSubview(userLabel)
        setUserConstraint()
        userLabel.text = "選擇提醒對象"
    }
    
    func setUserPicker() {
        view.addSubview(userPicker)
        setUserPickerContraint()
    }
    
    func setType() {
        view.addSubview(typeLabel)
        setTypeConstraint()
        typeLabel.text = "選擇類型"
    }
    
//    func setTypePicker() {
//        view.addSubview(typePicker)
//        setTypePickerConstraint()
//    }
    
    func setCompleteButton() {
        view.addSubview(completeButton)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        setCompleteButtonConstraint()
        completeButton.setTitle("設定", for: .normal)
        completeButton.backgroundColor = .systemGray
    }
    
    func setButtons() {
        view.addSubview(creditButton)
        view.addSubview(debtButton)
        setButtonsConstraint()
        creditButton.setTitle("收款", for: .normal)
        creditButton.titleLabel?.font = creditButton.titleLabel?.font.withSize(14)
        creditButton.backgroundColor = .systemTeal
        creditButton.addTarget(self, action: #selector(pressTypeButton), for: .touchUpInside)
        
        debtButton.setTitle("付款", for: .normal)
        debtButton.backgroundColor = .systemOrange
        debtButton.titleLabel?.font = debtButton.titleLabel?.font.withSize(14)
        debtButton.addTarget(self, action: #selector(pressTypeButton), for: .touchUpInside)
        
    }
    
    @objc func pressTypeButton(_ sender: UIButton) {
        
        if sender.isSelected == false {
            sender.layer.borderColor = UIColor.black.cgColor
            sender.layer.borderWidth = 1
            sender.isSelected = true
        } else {
            sender.layer.borderWidth = 0
            sender.isSelected = false
        }
        let buttonArray = [creditButton, debtButton]
        for button in buttonArray {
            if button.isSelected && button !== sender {
                button.isSelected = false
                button.layer.borderWidth = 0
            }
        }
    }
    
    func setGroupLabelConstraint() {
        groupLabel.translatesAutoresizingMaskIntoConstraints = false
        groupLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
        groupLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        groupLabel.widthAnchor.constraint(equalToConstant: 140).isActive = true
        groupLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func setGroupPickerConstraint() {
        groupPicker.translatesAutoresizingMaskIntoConstraints = false
        groupPicker.centerYAnchor.constraint(equalTo: groupLabel.centerYAnchor, constant: 0).isActive = true
        groupPicker.leftAnchor.constraint(equalTo: groupLabel.rightAnchor, constant: 30).isActive = true
        groupPicker.widthAnchor.constraint(equalToConstant: 180).isActive = true
        groupPicker.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func setUserConstraint() {
        userLabel.translatesAutoresizingMaskIntoConstraints = false
        userLabel.topAnchor.constraint(equalTo: groupLabel.bottomAnchor, constant: 20).isActive = true
        userLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        userLabel.widthAnchor.constraint(equalToConstant: 140).isActive = true
        userLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func setUserPickerContraint() {
        userPicker.translatesAutoresizingMaskIntoConstraints = false
        userPicker.centerYAnchor.constraint(equalTo: userLabel.centerYAnchor, constant: 0).isActive = true
        userPicker.leftAnchor.constraint(equalTo: userLabel.rightAnchor, constant: 30).isActive = true
        userPicker.widthAnchor.constraint(equalToConstant: 180).isActive = true
        userPicker.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func setTypeConstraint() {
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        typeLabel.topAnchor.constraint(equalTo: userLabel.bottomAnchor, constant: 20).isActive = true
        typeLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        typeLabel.widthAnchor.constraint(equalToConstant: 140).isActive = true
        typeLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
//    func setTypePickerConstraint() {
//        typePicker.translatesAutoresizingMaskIntoConstraints = false
//        typePicker.centerYAnchor.constraint(equalTo: typeLabel.centerYAnchor, constant: 0).isActive = true
//        typePicker.leadingAnchor.constraint(equalTo: userPicker.leadingAnchor, constant: 0).isActive = true
//        typePicker.widthAnchor.constraint(equalToConstant: 100).isActive = true
//        typePicker.heightAnchor.constraint(equalToConstant: 40).isActive = true
//    }
    
    func setButtonsConstraint() {
        creditButton.translatesAutoresizingMaskIntoConstraints = false
//        creditButton.topAnchor.constraint(equalTo: userLabel.bottomAnchor, constant: 20).isActive = true
        creditButton.centerYAnchor.constraint(equalTo: typeLabel.centerYAnchor, constant: 0).isActive = true
        creditButton.leadingAnchor.constraint(equalTo: userPicker.leadingAnchor, constant: 0).isActive = true
        creditButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        creditButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        debtButton.translatesAutoresizingMaskIntoConstraints = false
//        debtButton.topAnchor.constraint(equalTo: userLabel.bottomAnchor, constant: 20).isActive = true
        debtButton.centerYAnchor.constraint(equalTo: typeLabel.centerYAnchor, constant: 0).isActive = true
        debtButton.leadingAnchor.constraint(equalTo: creditButton.trailingAnchor, constant: 10).isActive = true
        debtButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        debtButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func setCompleteButtonConstraint() {
        completeButton.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 100).isActive = true
        completeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        completeButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        completeButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
}
