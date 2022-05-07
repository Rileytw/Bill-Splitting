//
//  AddReminderViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/20.
//

import UIKit

class AddReminderViewController: UIViewController {

    let currentUserId = AccountManager.shared.currentUser.currentUserId
    let groupLabel = UILabel()
    let groupPicker = BasePickerViewInTextField(frame: .zero)
    let userLabel = UILabel()
    let userPicker = BasePickerViewInTextField(frame: .zero)
    let typeLabel = UILabel()
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
    var blackList = [String]()
    var remindTimeStamp: Double?
    var reminderData = Reminder(groupId: "",
                                memberId: "",
                                creatorId: AccountManager.shared.currentUser.currentUserId,
                                type: 0,
                                remindTime: 0,
                                status: 1,
                                documentId: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        getGroupData()
        getUserData()
        fetchCurrentUserData()
        
        setGroup()
        setGroupPicker()
        setUser()
        setUserPicker()
        setType()
        setButtons()
        setReminderLael()
        setDatePicker()
        setCompleteButton()
        setDismissButton()
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
        GroupManager.shared.fetchGroups(userId: currentUserId, status: 0) { [weak self] result in
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
        groupLabel.textColor = .greenWhite
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
        userLabel.textColor = .greenWhite
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
        typeLabel.text = "提醒類型"
        typeLabel.textColor = .greenWhite
    }
    
    func setCompleteButton() {
        view.addSubview(completeButton)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        setCompleteButtonConstraint()
        completeButton.setTitle("設定", for: .normal)
        completeButton.backgroundColor = .systemGray
        completeButton.addTarget(self, action: #selector(pressComplete), for: .touchUpInside)
        ElementsStyle.styleSpecificButton(completeButton)
    }
    
    @objc func pressComplete() {
        
        if groupPicker.textField.text == "" || userPicker.textField.text == "" {
            loseInfoAlert(title: "資料不完整", message: "請確認是否已設定群組及提醒對象")
        } else if creditButton.isSelected == false && debtButton.isSelected == false {
            loseInfoAlert(title: "資料不完整", message: "請確認已選擇提醒類型")
        } else {
            addReminder()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func loseInfoAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "確認", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func addReminder() {
        reminderData.creatorId = currentUserId
        ReminderManager.shared.addReminderData(reminder: reminderData)
    }
    
    func setButtons() {
        view.addSubview(creditButton)
        view.addSubview(debtButton)
        setButtonsConstraint()
        creditButton.setTitle("收款", for: .normal)
        creditButton.titleLabel?.font = creditButton.titleLabel?.font.withSize(14)
        creditButton.backgroundColor = .styleLightBlue
        creditButton.addTarget(self, action: #selector(pressTypeButton), for: .touchUpInside)
        creditButton.setTitleColor(.styleBlue, for: .normal)
        
        debtButton.setTitle("付款", for: .normal)
        debtButton.backgroundColor = .styleYellow
        debtButton.titleLabel?.font = debtButton.titleLabel?.font.withSize(14)
        debtButton.addTarget(self, action: #selector(pressTypeButton), for: .touchUpInside)
        debtButton.setTitleColor(.styleBlue, for: .normal)
        
    }
    
    @objc func pressTypeButton(_ sender: UIButton) {
        if sender.isSelected == false {
            sender.layer.borderColor = UIColor.greenWhite.cgColor
            sender.layer.borderWidth = 1
            ElementsStyle.styleSelectedButton(sender)
            sender.isSelected = true
            
            if sender == creditButton {
                reminderData.type = RemindType.credit.intData
            } else {
                reminderData.type = RemindType.debt.intData
            }
        } else {
            sender.layer.borderWidth = 0
            sender.isSelected = false
            ElementsStyle.styleNotSelectedButton(sender)
        }
        let buttonArray = [creditButton, debtButton]
        for button in buttonArray {
            if button.isSelected && button !== sender {
                button.isSelected = false
                button.layer.borderWidth = 0
                ElementsStyle.styleNotSelectedButton(button)
            }
        }
    }
    
    func getUserData() {
        UserManager.shared.fetchUsersData { [weak self] result in
            switch result {
            case .success(let userData):
                self?.userData = userData
                self?.detectBlackListUser()
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
    }
    
    func selectedMember(membersId: [String]) {
        var memberData: [UserData] = []
        for memberId in membersId {
            for indexdata in userData where indexdata.userId == memberId {
                memberData.append(indexdata)
            }
        }
        member = memberData
        member = member.filter { $0.userId != currentUserId }
    }
    
    func setReminderLael() {
        view.addSubview(reminderLabel)
        setReminderLabelConstraint()
        reminderLabel.text = "設定提醒時間"
        reminderLabel.textColor = .greenWhite
    }
    
    func setDatePicker() {
        view.addSubview(remindTimeDatePicker)
        setDatePickerConstraint()
//        remindTimeDatePicker.datePickerMode = UIDatePicker.Mode.date
        remindTimeDatePicker.locale = Locale(identifier: "zh_Hant_TW")
        remindTimeDatePicker.contentHorizontalAlignment = .right
        remindTimeDatePicker.overrideUserInterfaceStyle = .dark
        remindTimeDatePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
    }
    
    @objc func datePickerChanged() {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
        let remindDate = remindTimeDatePicker.date
        remindTimeStamp = remindDate.timeIntervalSince1970
        reminderData.remindTime = remindTimeStamp ?? Date().timeIntervalSince1970
    }
    
    func fetchCurrentUserData() {
        UserManager.shared.fetchUserData(friendId: currentUserId) { [weak self] result in
            switch result {
            case .success(let currentUserData):
                if currentUserData?.blackList != nil {
                    self?.blackList = currentUserData?.blackList ?? []
                }
                print("success")
            case .failure(let error):
                print("\(error.localizedDescription)")
            }
        }
    }
    
    func detectBlackListUser() {
        let newUserData = UserManager.renameBlockedUser(blockList: blackList,
                                                        userData: userData)
        userData = newUserData
    }
    
    func setReminderLabelConstraint() {
        reminderLabel.translatesAutoresizingMaskIntoConstraints = false
        reminderLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 20).isActive = true
        reminderLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        reminderLabel.leadingAnchor.constraint(equalTo: typeLabel.leadingAnchor, constant: 0).isActive = true
        reminderLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
    }
    
    func setDatePickerConstraint() {
        remindTimeDatePicker.translatesAutoresizingMaskIntoConstraints = false
        remindTimeDatePicker.topAnchor.constraint(equalTo: creditButton.bottomAnchor, constant: 20).isActive = true
        remindTimeDatePicker.heightAnchor.constraint(equalToConstant: 40).isActive = true
        remindTimeDatePicker.leadingAnchor.constraint(equalTo: reminderLabel.trailingAnchor, constant: 5).isActive = true
        remindTimeDatePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
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
        completeButton.widthAnchor.constraint(equalToConstant: 180).isActive = true
        completeButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func setDismissButton() {
        let dismissButton = UIButton()
        view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.tintColor = UIColor.greenWhite
        dismissButton.addTarget(self, action: #selector(pressDismiss), for: .touchUpInside)
    }
    
    @objc func pressDismiss() {
        self.dismiss(animated: true, completion: nil)
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
            if groupPickerData.isEmpty == false {
                return groupPickerData[row]
            } else {
                return "目前暫無群組"
            }
            
        } else {
            return member[row].userName
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == groupPicker.pickerView {
            if groupPickerData.isEmpty == false {
                let groupMember = groups[row].member
                selectedMember(membersId: groupMember)
                reminderData.groupId = groups[row].groupId
                return groupPicker.textField.text = groupPickerData[row]
            } else {
               pickGroupAlert(title: "目前沒有群組", message: "請先建立群組，才能建立提醒喔！")
            }
            
        } else {
            if member.isEmpty == false {
                reminderData.memberId = member[row].userId
                return userPicker.textField.text = member[row].userName
            } else {
               pickGroupAlert(title: "請先選擇群組", message: "選擇群組後，才能選擇提醒對象喔！")
            }
        }
    }
    
    func pickGroupAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "確認", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
