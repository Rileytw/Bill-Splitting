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
    var groupPickerData: [String] = []
    var remindTimeDatePicker = UIDatePicker()
    var reminderLabel = UILabel()
    
    var groups: [GroupData] = []
    var member: [UserData] = []
    var userData: [UserData] = []
    var remindTimeStamp: Double?
    var reminderData = Reminder(groupId: "", memberId: "", creatorId: userId, type: 0, remindTime: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getGroupData()
        getUserData()
        
        setGroup()
        setGroupPicker()
        setUser()
        setUserPicker()
        setType()
        setButtons()
        setReminderLael()
        setDatePicker()
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

    func getGroupData() {
        GroupManager.shared.fetchGroups(userId: userId) { [weak self] result in
            switch result {
            case .success(let groups):
                self?.groups = groups
                self?.groupPicker.pickerViewData = groups.map { $0.groupName }
                self?.groupPickerData = groups.map { $0.groupName }
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
    }
    
    func setGroup() {
        view.addSubview(groupLabel)
        setGroupLabelConstraint()
        groupLabel.text = "選擇群組"
    }
    
    func setGroupPicker() {
        view.addSubview(groupPicker)
        setGroupPickerConstraint()
        
        groupPicker.pickerView.dataSource = self
        groupPicker.pickerView.delegate = self
    }
    
    func setUser() {
        view.addSubview(userLabel)
        setUserConstraint()
        userLabel.text = "選擇提醒對象"
    }
    
    func setUserPicker() {
        view.addSubview(userPicker)
        setUserPickerContraint()
        
        userPicker.pickerView.dataSource = self
        userPicker.pickerView.delegate = self
    }
    
    func setType() {
        view.addSubview(typeLabel)
        setTypeConstraint()
        typeLabel.text = "選擇類型"
    }
    
    func setCompleteButton() {
        view.addSubview(completeButton)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        setCompleteButtonConstraint()
        completeButton.setTitle("設定", for: .normal)
        completeButton.backgroundColor = .systemGray
        completeButton.addTarget(self, action: #selector(pressComplete), for: .touchUpInside)
    }
    
    @objc func pressComplete() {
        addReminder()
        self.dismiss(animated: true, completion: nil)
    }
    
    func addReminder() {
        reminderData.creatorId = userId
        ReminderManager.shared.addReminderData(reminder: reminderData)
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
            
            if sender == creditButton {
                reminderData.type = RemindType.credit.intData
            } else {
                reminderData.type = RemindType.debt.intData
            }
//            switch sender {
//                case .creditButton:
//                  reminderData.type = RemindType.credit.intData
//                case .debtButton:
//                  reminderData.type = RemindType.debt.intData
////            }
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
    
    func getUserData() {
        UserManager.shared.fetchUsersData { [weak self] result in
            switch result {
            case .success(let userData):
                self?.userData = userData
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
    }
    
    func selectedMember(membersId: [String]) {
        var memberData: [UserData] = []
        for memberId in membersId {
            for indexdata in userData where indexdata.userId == memberId  {
//                if userData[index].userId == memberId {
//                    memberData.append(userData[index])
                memberData.append(indexdata)
//                }
            }
        }
        member = memberData
        member = member.filter { $0.userId != userId }
    }
    
    func setReminderLael() {
        view.addSubview(reminderLabel)
        setReminderLabelConstraint()
        reminderLabel.text = "選擇提醒時間"
    }
    
    func setDatePicker() {
        view.addSubview(remindTimeDatePicker)
        setDatePickerConstraint()
        remindTimeDatePicker.datePickerMode = UIDatePicker.Mode.date
        remindTimeDatePicker.locale = Locale(identifier: "zh_Hant_TW")
        remindTimeDatePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
    }
    
    @objc func datePickerChanged() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let remindDate = remindTimeDatePicker.date
        remindTimeStamp = remindDate.timeIntervalSince1970
        reminderData.remindTime = remindTimeStamp ?? 0
    }
    
    func setReminderLabelConstraint() {
        reminderLabel.translatesAutoresizingMaskIntoConstraints = false
        reminderLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 20).isActive = true
        reminderLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        reminderLabel.leadingAnchor.constraint(equalTo: typeLabel.leadingAnchor, constant: 0).isActive = true
        reminderLabel.widthAnchor.constraint(equalToConstant: 140).isActive = true
    }
    
    func setDatePickerConstraint() {
        remindTimeDatePicker.translatesAutoresizingMaskIntoConstraints = false
        remindTimeDatePicker.topAnchor.constraint(equalTo: creditButton.bottomAnchor, constant: 20).isActive = true
        remindTimeDatePicker.heightAnchor.constraint(equalToConstant: 40).isActive = true
        remindTimeDatePicker.leadingAnchor.constraint(equalTo: userPicker.leadingAnchor, constant: 0).isActive = true
        remindTimeDatePicker.widthAnchor.constraint(equalToConstant: 160).isActive = true
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
    
    func setButtonsConstraint() {
        creditButton.translatesAutoresizingMaskIntoConstraints = false
        creditButton.centerYAnchor.constraint(equalTo: typeLabel.centerYAnchor, constant: 0).isActive = true
        creditButton.leadingAnchor.constraint(equalTo: userPicker.leadingAnchor, constant: 0).isActive = true
        creditButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        creditButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        debtButton.translatesAutoresizingMaskIntoConstraints = false
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

extension AddReminderViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == groupPicker.pickerView {
            return groups.count
        } else {
            return member.count
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == groupPicker.pickerView {
            return groupPickerData[row]
        } else {
            return member[row].userName
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == groupPicker.pickerView {
            let groupMember = groups[row].member
            selectedMember(membersId: groupMember)
            reminderData.groupId = groups[row].groupId
            return groupPicker.textField.text = groupPickerData[row]
        } else {
            reminderData.memberId = member[row].userId
            if groups[row].creator != userId {
                return userPicker.textField.text = userName
            } else {
                return userPicker.textField.text = member[row].userName
            }
        }
    }
}
