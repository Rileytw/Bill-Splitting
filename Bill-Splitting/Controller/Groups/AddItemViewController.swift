//
//  AddItemViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/14.
//

import UIKit

class AddItemViewController: BaseViewController {
    
    // MARK: - Property
    let currentUserId = UserManager.shared.currentUser?.userId ?? ""
    let addItemView = AddItemView(frame: .zero)
    let typePickerView = BasePickerViewInTextField(frame: .zero)
    var typePickerViewData = [SplitType.equal.label, SplitType.percent.label, SplitType.customize.label]
    var memberPickerView = BasePickerViewInTextField(frame: .zero)
    let addButton = UIButton()
    let tableView = UITableView()
    let typeLabel = UILabel()
    let dismissButton = UIButton()
    var choosePaidMember = UILabel()
    var chooseInvolvedMember = UILabel()
    var addMoreButton = UIButton()
    
    var group: GroupData?
    var itemId: String?
    var paidId: String?
    var paidPrice: Double?
    var involvedExpenseData: [ExpenseInfo] = []
    var involvedPrice: Double?
    
    var isItemExist: Bool = false
    var itemData: ItemData?
    
    var selectedIndexs = [Int]()
    var involvedMemberName: [String] = []
    
    var itemImageString: String?
    var itemDescription: String?
    var itemImage: UIImage?
    
    typealias EditItem = (String) -> Void
    var editingItem: EditItem?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        setAddButton()
        setAddItemView()
        setTypeLabel()
        setTypePickerView()
        setmemberPickerView()
        setAddMoreButton()
        setInvolvedMembers()
        setTableView()
        setDismissButton()
        detectBlockListUser()
        networkDetect()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        ElementsStyle.styleTextField(addItemView.itemNameTextField)
        ElementsStyle.styleTextField(addItemView.priceTextField)
    }
    
    // MARK: - Method
    @objc func pressAddMore() {
        let storyBoard = UIStoryboard(name: StoryboardCategory.groups, bundle: nil)
        guard let addMoreInfoViewController = storyBoard.instantiateViewController(
            withIdentifier: String(describing: AddMoreInfoViewController.self)
        ) as? AddMoreInfoViewController else { return }
        
        if isItemExist == true {
            addMoreInfoViewController.itemData = itemData
            addMoreInfoViewController.isItemExist = true
        }
        
        if itemImage != nil {
            addMoreInfoViewController.photoImageView.image = itemImage
        }
        
        if itemDescription != nil {
            addMoreInfoViewController.descriptionTextView.text = itemDescription
        }
        
        addMoreInfoViewController.urlData = { [weak self] urlString in
            self?.itemImageString = urlString
        }
        addMoreInfoViewController.itemDescription = { [weak self] itemDes in
            self?.itemDescription = itemDes
        }
        
        addMoreInfoViewController.itemImage = { [weak self] photo in
            self?.itemImage = photo
            
        }
        
        self.present(addMoreInfoViewController, animated: true, completion: nil)
    }
    
    @objc func pressAddButton() {
        if NetworkStatus.shared.isConnected == true {
            let involvedTotalPrice = countInvolvedPrice()
            if addItemView.itemNameTextField.text == "" ||
                addItemView.priceTextField.text == "" ||
                typePickerView.textField.text == "" {
                lossInfoAlert(message: "請確認是否填寫款項名稱、支出金額並選擇分款方式")
            } else if memberPickerView.textField.text == "" && group?.type == GroupType.multipleUsers.typeInt {
                lossInfoAlert(message: "請確認是否選取付款人")
            } else if involvedExpenseData.isEmpty == true {
                lossInfoAlert(message: "請確認是否選取參與人")
            } else if typePickerView.textField.text == SplitType.percent.label && involvedTotalPrice != 100 {
                lossInfoAlert(message: "請確認分帳比例是否正確")
            } else if typePickerView.textField.text == SplitType.customize.label {
                let userInputPaid = addItemView.priceTextField.text ?? ""
                if let paidPrice = Double(userInputPaid) {
                    if involvedTotalPrice != paidPrice {
                        lossInfoAlert(message: "請確認自訂金額是否正確")
                    } else {
                        confirmAddItem()
                        setAnimation()
                    }
                }
            } else {
                confirmAddItem()
                setAnimation()
            }
        } else {
            networkConnectAlert()
        }
    }
    
    func getImageURL() {
        if let itemImage = itemImage {
            let fileName = "\(currentUserId)" + "\(Date())"
            ImageManager.shared.uploadImageToStorage(image: itemImage, fileName: fileName) { [weak self] urlString in
                self?.itemImageString = urlString
                self?.addItem()
            }
        } else {
            addItem()
        }
    }
    
    func confirmAddItem() {
        if isItemExist == true {
            deleteItem()
        } else {
            getImageURL()
        }
    }
    
    func countInvolvedPrice() -> Double {
        var involvedTotalPrice: Double = 0
        for involvePrice in involvedExpenseData {
            involvedTotalPrice += involvePrice.price
        }
        return involvedTotalPrice
    }
    
    func lossInfoAlert(message: String) {
        confirmAlert(title: "請填寫完整資訊", message: message)
    }
    
    func addItem() {
        var item = ItemData()
        item.groupId = group?.groupId ?? ""
        item.itemName = addItemView.itemNameTextField.text ?? ""
        item.itemDescription = itemDescription
        item.createdTime = Double(NSDate().timeIntervalSince1970)
        item.itemImage = itemImageString
        ItemManager.shared.addItemData(itemData: item) { [weak self] itemId in
            self?.itemId = itemId
            self?.allItemInfoUpload()
        }
    }
    
    private func addNotifyInDatabase() {
        ItemManager.shared.addNotify(grpupId: self.group?.groupId ?? "") { result in
            switch result {
            case .success:
                print("uplaod notification collection successfully")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func allItemInfoUpload() {
        var paidUserId: String?
        if group?.type == GroupType.multipleUsers.typeInt {
            paidUserId = paidId
        } else {
            paidUserId = currentUserId
        }
        paidPrice = Double(addItemView.priceTextField.text ?? "0")
        let paidPrice = paidPrice
        
        var involvedPrice: [Double] = []
        for user in 0..<involvedExpenseData.count {
            if self.typePickerView.textField.text == SplitType.equal.label {
                involvedPrice.append(Double(paidPrice ?? 0) / Double(selectedIndexs.count))
            } else if typePickerView.textField.text == SplitType.percent.label {
                involvedPrice.append((Double(involvedExpenseData[user].price)/100.00) * Double(paidPrice ?? 0))
            } else {
                involvedPrice.append(involvedExpenseData[user].price)
            }
        }
        guard let groupId = group?.groupId,
              let itemId = itemId,
              let paidUserId = paidUserId,
              let paidPrice = paidPrice
        else { return }
        
        AddItemManager.shared.addItem(groupId: groupId, itemId: itemId,
                                      paidUserId: paidUserId, paidPrice: paidPrice,
                                      involvedExpenseData: self.involvedExpenseData,
                                      involvedPrice: involvedPrice) { [weak self] in
            self?.removeAnimation()
            if AddItemManager.shared.isDataUploadSucces == true {
                self?.showSuccess(text: "新增成功")
                if self?.isItemExist == true {
                    self?.editingItem?(self?.itemId ?? "")
                }
                self?.addNotifyInDatabase()
                
            } else {
                self?.showFailure(text: ErrorType.generalError.errorMessage)
                
            }
            self?.dismiss(animated: false, completion: nil)
        }
    }
    
    func deleteItem() {
        reCountPersonalExpense()
        ItemManager.shared.deleteItem(itemId: itemData?.itemId ?? "") { [weak self] result in
            switch result {
            case .success:
                print("success")
                self?.getImageURL()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func reCountPersonalExpense() {
        guard let group = group,
              let item = itemData
        else { return }
        
        GroupManager.shared.updatePersonalExpense(groupId: group.groupId, item: item) { [weak self] in
            if !GroupManager.shared.isExpenseUpdateSucces == true {
                self?.showFailure(text: ErrorType.generalError.errorMessage)
            }
        }
    }
    
    func networkConnectAlert() {
        confirmAlert(title: "網路未連線", message: "網路未連線，無法新增款項資料，請確認網路連線後再新增。")
    }
    
    func setTypeLabel() {
        view.addSubview(typeLabel)
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        typeLabel.topAnchor.constraint(equalTo: addItemView.bottomAnchor, constant: 20).isActive = true
        typeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        typeLabel.widthAnchor.constraint(equalToConstant: 140).isActive = true
        typeLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        typeLabel.text = "選擇分款方式"
        typeLabel.textColor = UIColor.greenWhite
    }
    
    func setDismissButton() {
        view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        dismissButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 36).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.tintColor = UIColor.greenWhite
        dismissButton.addTarget(self, action: #selector(pressDismiss), for: .touchUpInside)
    }
    
    @objc func pressDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func detectBlockListUser() {
        let blockList = UserManager.shared.currentUser?.blackList
        guard let blockList = blockList else { return }
        let newUserData = UserManager.renameBlockedUser(blockList: blockList,
                                                        userData: group?.memberData ?? [])
        group?.memberData = newUserData
        tableView.reloadData()
    }
}

extension AddItemViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return typePickerViewData.count
        } else {
            return group?.memberData?.count ?? 1
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return typePickerViewData[row]
        } else {
            return group?.memberData?[row].userName
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            tableView.reloadData()
            return typePickerView.textField.text = typePickerViewData[row]
        } else {
            paidId = group?.memberData?[row].userId
            paidPrice = Double(addItemView.priceTextField.text ?? "0")
            return memberPickerView.textField.text = group?.memberData?[row].userName
        }
    }
}

extension AddItemViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return group?.memberData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: AddItemTableViewCell.self),
            for: indexPath
        )
        
        guard let memberCell = cell as? AddItemTableViewCell else { return cell }
        
        memberCell.memberName.text = group?.memberData?[indexPath.row].userName
        
        if typePickerView.textField.text == SplitType.equal.label {
            if selectedIndexs.contains(indexPath.row) {
                memberCell.createEqualType(selectedType: .selected, selectedNumber: selectedIndexs.count)
            } else {
                memberCell.createEqualType(selectedType: .unselected, selectedNumber: nil)
            }
        } else if typePickerView.textField.text == SplitType.percent.label {
            if selectedIndexs.contains(indexPath.row) {
                memberCell.createPercentType(selectedType: .selected)
            } else {
                memberCell.createPercentType(selectedType: .unselected)
            }
        } else if typePickerView.textField.text == SplitType.customize.label {
            if selectedIndexs.contains(indexPath.row) {
                memberCell.createCustomizeType(selectedType: .selected)
            } else {
                memberCell.createCustomizeType(selectedType: .unselected)
            }
        }
        memberCell.delegate = self
        return memberCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let index = selectedIndexs.index(of: indexPath.row) {
            selectedIndexs.remove(at: index)
            involvedMemberName.remove(at: index)
            involvedExpenseData.remove(at: index)
        } else {
            selectedIndexs.append(indexPath.row)
            involvedMemberName.append(group?.memberData?[indexPath.row].userName ?? "")
            
            //            let involedExpense = ExpenseInfo(userId: group?.memberData?[indexPath.row].userId ?? "", price: 0)
            var involedExpense = ExpenseInfo()
            involedExpense.userId = group?.memberData?[indexPath.row].userId ?? ""
            involedExpense.price = 0
            
            involvedExpenseData.append(involedExpense)
        }
        self.tableView.reloadData()
    }
}

extension AddItemViewController: AddItemTableViewCellDelegate {
    func endEditing(_ cell: AddItemTableViewCell) {
        
        involvedPrice = Double(cell.priceTextField.text ?? "0")
        
        let name = cell.memberName.text
        let selectedUser = group?.memberData?.filter { $0.userName == name }
        guard let id = selectedUser?[0].userId else { return }
        
        for index in 0..<involvedExpenseData.count {
            if involvedExpenseData[index].userId == id {
                involvedExpenseData[index].price = involvedPrice ?? 0
            }
        }
    }
}

extension AddItemViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == typePickerView.textField {
            if textField.text?.isEmpty == true {
                typePickerView.pickerView.selectRow(0, inComponent: 0, animated: true)
                self.pickerView(typePickerView.pickerView, didSelectRow: 0, inComponent: 0)
            }
        } else if textField == memberPickerView.textField {
            if textField.text?.isEmpty == true {
                memberPickerView.pickerView.selectRow(0, inComponent: 0, animated: true)
                self.pickerView(memberPickerView.pickerView, didSelectRow: 0, inComponent: 0)
            }
        }
    }
}

extension AddItemViewController {
    fileprivate func setAddItemViewConstaint() {
        addItemView.translatesAutoresizingMaskIntoConstraints = false
        addItemView.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 10).isActive = true
        addItemView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        addItemView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        addItemView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    func setAddItemView() {
        view.addSubview(addItemView)
        setAddItemViewConstaint()
        addItemView.itemName.text = "項目名稱"
        addItemView.priceLabel.text = "支出金額"
        addItemView.priceTextField.keyboardType = .numberPad
        
        if isItemExist == true {
            addItemView.itemNameTextField.text = itemData?.itemName
            addItemView.priceTextField.text = String(itemData?.paidInfo?[0].price ?? 0)
        }
    }
    
    fileprivate func setPickerViewConstraint() {
        typePickerView.translatesAutoresizingMaskIntoConstraints = false
        typePickerView.topAnchor.constraint(equalTo: addItemView.bottomAnchor, constant: 20).isActive = true
        typePickerView.leadingAnchor.constraint(equalTo: typeLabel.trailingAnchor, constant: 10).isActive = true
        typePickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        typePickerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func setTypePickerView() {
        view.addSubview(typePickerView)
        setPickerViewConstraint()
        typePickerView.pickerViewData = typePickerViewData
        
        typePickerView.pickerView.dataSource = self
        typePickerView.pickerView.delegate = self
        typePickerView.textField.delegate = self
        
        typePickerView.pickerView.tag = 0
    }
    
    fileprivate func setMemberPickerViewConstraint() {
        choosePaidMember.translatesAutoresizingMaskIntoConstraints = false
        choosePaidMember.topAnchor.constraint(equalTo: typePickerView.bottomAnchor, constant: 20).isActive = true
        choosePaidMember.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        choosePaidMember.widthAnchor.constraint(equalToConstant: 100).isActive = true
        choosePaidMember.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func setmemberPickerView() {
        view.addSubview(choosePaidMember)
        setMemberPickerViewConstraint()
        choosePaidMember.text = "選擇付款人"
        choosePaidMember.textColor = UIColor.greenWhite
        if group?.type == 0 {
            choosePaidMember.isHidden = true
        }
        
        view.addSubview(memberPickerView)
        memberPickerView.translatesAutoresizingMaskIntoConstraints = false
        memberPickerView.topAnchor.constraint(equalTo: typePickerView.bottomAnchor, constant: 20).isActive = true
        memberPickerView.leadingAnchor.constraint(equalTo: choosePaidMember.trailingAnchor, constant: 20).isActive = true
        memberPickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        memberPickerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        memberPickerView.pickerView.dataSource = self
        memberPickerView.pickerView.delegate = self
        memberPickerView.textField.delegate = self
        memberPickerView.pickerView.tag = 1
        
        if group?.type == 0 {
            memberPickerView.isHidden = true
            memberPickerView.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }
    }
    
    func setAddButton() {
        view.addSubview(addButton)
        addButton.setTitle("完成", for: .normal)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        ElementsStyle.styleSpecificButton(addButton)
        
        addButton.addTarget(self, action: #selector(pressAddButton), for: .touchUpInside)
    }
    
    func setAddMoreButton() {
        view.addSubview(addMoreButton)
        addMoreButton.translatesAutoresizingMaskIntoConstraints = false
        addMoreButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        addMoreButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        addMoreButton.widthAnchor.constraint(equalToConstant: 180).isActive = true
        addMoreButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        addMoreButton.backgroundColor = .systemTeal
        addMoreButton.setImage(UIImage(systemName: "paperclip"), for: .normal)
        addMoreButton.setTitle("新增照片及說明", for: .normal)
        addMoreButton.tintColor = .white
        addMoreButton.addTarget(self, action: #selector(pressAddMore), for: .touchUpInside)
        ElementsStyle.styleSpecificButton(addMoreButton)
    }
    
    func setInvolvedMembers() {
        view.addSubview(chooseInvolvedMember)
        chooseInvolvedMember.translatesAutoresizingMaskIntoConstraints = false
        chooseInvolvedMember.topAnchor.constraint(equalTo: choosePaidMember.bottomAnchor, constant: 10).isActive = true
        chooseInvolvedMember.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        chooseInvolvedMember.widthAnchor.constraint(equalToConstant: 100).isActive = true
        chooseInvolvedMember.heightAnchor.constraint(equalToConstant: 40).isActive = true
        chooseInvolvedMember.text = "選擇參與人"
        chooseInvolvedMember.textColor = UIColor.greenWhite
    }
    
    func setTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: chooseInvolvedMember.bottomAnchor, constant: 5).isActive = true
        tableView.bottomAnchor.constraint(equalTo: addMoreButton.topAnchor, constant: -10).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        tableView.backgroundColor = .clear
        
        tableView.register(UINib(nibName: String(describing: AddItemTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: AddItemTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
    }
}
