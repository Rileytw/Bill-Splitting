//
//  AddItemViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/14.
//

import UIKit

class AddItemViewController: UIViewController {

    let currentUserId = AccountManager.shared.currentUser.currentUserId
    let addItemView = AddItemView(frame: .zero)
    let typePickerView = BasePickerViewInTextField(frame: .zero)
    var typePickerViewData = [SplitType.equal.label, SplitType.percent.label, SplitType.customize.label]
    var memberPickerView = BasePickerViewInTextField(frame: .zero)
    let addButton = UIButton()
    let tableView = UITableView()
    let typeLabel = UILabel()
    let dismissButton = UIButton()
    
    var groupData: GroupData? 
    var memberId: [String]?
    var memberData: [UserData]? = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var itemId: String?
    var paidItem: [[ExpenseInfo]] = []
    var involvedItem: [[ExpenseInfo]] = []
    var paidId: String?
    var paidPrice: Double?
    var involvedExpenseData: [ExpenseInfo] = []
    var involvedPrice: Double?
    var choosePaidMember = UILabel()
    var chooseInvolvedMember = UILabel()
    var addMoreButton = UIButton()
    
    var isItemExist: Bool = false
    var itemData: ItemData?
    
    var selectedIndexs = [Int]() {
        didSet {
            if typePickerView.textField.text == SplitType.equal.label {
                tableView.reloadData()
            }
        }
    }
    var involvedMemberName: [String] = []
    
    var itemImageString: String?
    var itemDescription: String?
    
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
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
//        addMoreButton.layer.cornerRadius = 0.5 * addMoreButton.bounds.size.width
//        addMoreButton.clipsToBounds = true
        ElementsStyle.styleTextField(addItemView.itemNameTextField)
        ElementsStyle.styleTextField(addItemView.priceTextField)
    }
    
    func setAddItemView() {
        view.addSubview(addItemView)
        addItemView.translatesAutoresizingMaskIntoConstraints = false
        addItemView.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 10).isActive = true
        addItemView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        addItemView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        addItemView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        addItemView.itemName.text = "項目名稱"
        addItemView.priceLabel.text = "支出金額"
        
        if isItemExist == true {
            addItemView.itemNameTextField.text = itemData?.itemName
            addItemView.priceTextField.text = String(itemData?.paidInfo?[0].price ?? 0)
        }
    }

    func setTypePickerView() {
        view.addSubview(typePickerView)
        typePickerView.translatesAutoresizingMaskIntoConstraints = false
        typePickerView.topAnchor.constraint(equalTo: addItemView.bottomAnchor, constant: 40).isActive = true
        typePickerView.leadingAnchor.constraint(equalTo: typeLabel.trailingAnchor, constant: 10).isActive = true
        typePickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        typePickerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        typePickerView.pickerViewData = typePickerViewData
        
        typePickerView.pickerView.dataSource = self
        typePickerView.pickerView.delegate = self
        
        typePickerView.pickerView.tag = 0
    }
    
    func setmemberPickerView() {
        view.addSubview(choosePaidMember)
        choosePaidMember.translatesAutoresizingMaskIntoConstraints = false
        choosePaidMember.topAnchor.constraint(equalTo: typePickerView.bottomAnchor, constant: 40).isActive = true
        choosePaidMember.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        choosePaidMember.widthAnchor.constraint(equalToConstant: 100).isActive = true
        choosePaidMember.heightAnchor.constraint(equalToConstant: 40).isActive = true
        choosePaidMember.text = "選擇付款人"
        choosePaidMember.textColor = UIColor.greenWhite
        if groupData?.type == 0 {
            choosePaidMember.isHidden = true
        }
        
        view.addSubview(memberPickerView)
        memberPickerView.translatesAutoresizingMaskIntoConstraints = false
        memberPickerView.topAnchor.constraint(equalTo: typePickerView.bottomAnchor, constant: 40).isActive = true
        memberPickerView.leadingAnchor.constraint(equalTo: choosePaidMember.trailingAnchor, constant: 20).isActive = true
        memberPickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
//        typePickerView.leadingAnchor.constraint(equalTo: typeLabel.trailingAnchor, constant: 10).isActive = true
//        typePickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        memberPickerView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        memberPickerView.pickerView.dataSource = self
        memberPickerView.pickerView.delegate = self
        memberPickerView.pickerView.tag = 1
        
        if groupData?.type == 0 {
            memberPickerView.isHidden = true
            memberPickerView.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }
    }
    
    func setAddButton() {
        view.addSubview(addButton)
        addButton.setTitle("完成", for: .normal)
//        addButton.backgroundColor = .systemGray
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        ElementsStyle.styleSpecificButton(addButton)
        
        addButton.addTarget(self, action: #selector(pressAddButton), for: .touchUpInside)
    }
    
    func setAddMoreButton() {
        view.addSubview(addMoreButton)
        addMoreButton.translatesAutoresizingMaskIntoConstraints = false
        addMoreButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        addMoreButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        addMoreButton.widthAnchor.constraint(equalToConstant: 160).isActive = true
        addMoreButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        addMoreButton.backgroundColor = .systemTeal
        addMoreButton.setImage(UIImage(systemName: "paperclip"), for: .normal)
        addMoreButton.setTitle(" 更多資訊", for: .normal)
        addMoreButton.tintColor = .white
        addMoreButton.addTarget(self, action: #selector(pressAddMore), for: .touchUpInside)
        ElementsStyle.styleSpecificButton(addMoreButton)
    }
    
    @objc func pressAddMore() {
        let storyBoard = UIStoryboard(name: "Groups", bundle: nil)
        guard let addMoreInfoViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: AddMoreInfoViewController.self)) as? AddMoreInfoViewController else { return }
        
        if isItemExist == true {
            addMoreInfoViewController.itemData = itemData
            addMoreInfoViewController.isItemExist = true
        }
       
        addMoreInfoViewController.urlData = { [weak self] urlString in
            self?.itemImageString = urlString
        }
        addMoreInfoViewController.itemDescription = { [weak self] itemDes in
            self?.itemDescription = itemDes
        }
        
        self.present(addMoreInfoViewController, animated: true, completion: nil)
    }
    
    func setInvolvedMembers() {
        view.addSubview(chooseInvolvedMember)
        chooseInvolvedMember.translatesAutoresizingMaskIntoConstraints = false
        chooseInvolvedMember.topAnchor.constraint(equalTo: choosePaidMember.bottomAnchor, constant: 20).isActive = true
        chooseInvolvedMember.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        chooseInvolvedMember.widthAnchor.constraint(equalToConstant: 100).isActive = true
        chooseInvolvedMember.heightAnchor.constraint(equalToConstant: 40).isActive = true
        chooseInvolvedMember.text = "選擇參與人"
        chooseInvolvedMember.textColor = UIColor.greenWhite
    }
    
    func setTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: chooseInvolvedMember.bottomAnchor, constant: 10).isActive = true
        tableView.bottomAnchor.constraint(equalTo: addMoreButton.topAnchor, constant: -10).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        tableView.backgroundColor = .clear
        
        tableView.register(UINib(nibName: String(describing: AddItemTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: AddItemTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @objc func pressAddButton() {
        if isItemExist == true {
            deleteItem() {
                addItem()
            }
        } else {
            addItem()
        }
        
        self.dismiss(animated: false, completion: nil)
    }
    
    func addItem() {
        ItemManager.shared.addItemData(groupId: groupData?.groupId ?? "",
                                       itemName: addItemView.itemNameTextField.text ?? "",
                                       itemDescription: itemDescription,
                                       createdTime: Double(NSDate().timeIntervalSince1970),
                                       itemImage: self.itemImageString) { itemId in
            self.itemId = itemId
            
            var paidUserId: String?
            if self.groupData?.type == 1 {
                paidUserId = self.paidId
            } else {
                paidUserId = self.currentUserId
            }
            
            self.paidPrice = Double(self.addItemView.priceTextField.text ?? "0")
            let paidPrice = self.paidPrice
            
            ItemManager.shared.addPaidInfo(paidUserId: paidUserId ?? "",
                                           price: paidPrice ?? 0,
                                           itemId: itemId,
                                           createdTime: Double(NSDate().timeIntervalSince1970))

            for user in 0..<self.involvedExpenseData.count {
                var involvedPrice: Double?
                if self.typePickerView.textField.text == SplitType.equal.label {
                    involvedPrice = (Double(100 / self.selectedIndexs.count)/100) * (paidPrice ?? 0)
                } else if self.typePickerView.textField.text == SplitType.percent.label {
                    involvedPrice = ((self.involvedExpenseData[user].price)/100) * (paidPrice ?? 0)
                } else {
                    involvedPrice = self.involvedExpenseData[user].price
                }
                ItemManager.shared.addInvolvedInfo(involvedUserId: self.involvedExpenseData[user].userId,
                                                   price: involvedPrice ?? 0,
                                                   itemId: itemId,
                                                   createdTime: Double(NSDate().timeIntervalSince1970))
            }
            self.countPersonalExpense()
        }
    }
    
    func countPersonalExpense() {
        
        var paidUserId: String?
        if self.groupData?.type == 1 {
            paidUserId = self.paidId
        } else {
            paidUserId = currentUserId
        }
        
        let paidPrice = self.paidPrice
        
        GroupManager.shared.updateMemberExpense(userId: paidUserId ?? "",
                                                newExpense: self.paidPrice ?? 0,
                                                groupId: groupData?.groupId ?? "")
        
        for user in 0..<self.involvedExpenseData.count {
            var involvedPrice: Double?
            if self.typePickerView.textField.text == SplitType.equal.label {
                involvedPrice = (Double(100 / self.selectedIndexs.count)/100) * (paidPrice ?? 0)
            } else if self.typePickerView.textField.text == SplitType.percent.label {
                involvedPrice = ((self.involvedExpenseData[user].price)/100) * (paidPrice ?? 0)
            } else {
                involvedPrice = self.involvedExpenseData[user].price
            }
            guard let involvedPrice = involvedPrice else { return }
            GroupManager.shared.updateMemberExpense(userId: self.involvedExpenseData[user].userId,
                                                    newExpense: 0 - involvedPrice,
                                                    groupId: groupData?.groupId ?? "")
        }
    }
    
    func deleteItem(completion: () -> Void) {
        reCountPersonalExpense()
        ItemManager.shared.deleteItem(itemId: itemData?.itemId ?? "")
        completion()
    }
    
    func reCountPersonalExpense() {
        guard let paidUserId = itemData?.paidInfo?[0].userId,
              let paidPrice = itemData?.paidInfo?[0].price
        else { return }
        
        GroupManager.shared.updateMemberExpense(userId: paidUserId ,
                                                newExpense: 0 - paidPrice,
                                                groupId: groupData?.groupId ?? "")
        
        guard let involvedExpense = itemData?.involedInfo else { return }
        
        for user in 0..<involvedExpense.count {
            GroupManager.shared.updateMemberExpense(userId: involvedExpense[user].userId,
                                                    newExpense: involvedExpense[user].price,
                                                    groupId: groupData?.groupId ?? "")
        }
    }
    
    func setTypeLabel() {
        view.addSubview(typeLabel)
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        typeLabel.topAnchor.constraint(equalTo: addItemView.bottomAnchor, constant: 40).isActive = true
        typeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        typeLabel.widthAnchor.constraint(equalToConstant: 140).isActive = true
        typeLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        typeLabel.text = "選擇分款方式"
        typeLabel.textColor = UIColor.greenWhite
    }
    
    func setDismissButton() {
        view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        dismissButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
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

extension AddItemViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return typePickerViewData.count
        } else {
            return memberData?.count ?? 1
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return typePickerViewData[row]
        } else {
            return memberData?[row].userName
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            tableView.reloadData()
            return typePickerView.textField.text = typePickerViewData[row]
        } else {
            paidId = memberData?[row].userId
            paidPrice = Double(addItemView.priceTextField.text ?? "0")
            return memberPickerView.textField.text = memberData?[row].userName
        }
    }
}

extension AddItemViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: AddItemTableViewCell.self),
            for: indexPath
        )
        
        guard let memberCell = cell as? AddItemTableViewCell else { return cell }
        
        memberCell.memberName.text = memberData?[indexPath.row].userName
        
        if typePickerView.textField.text == SplitType.equal.label {
            if selectedIndexs.contains(indexPath.row) {
                memberCell.selectedButton.isSelected = true
                memberCell.equalLabel.isHidden = false
                memberCell.percentLabel.text = "%"
                memberCell.percentLabel.isHidden = false
                memberCell.equalLabel.text = "\(100 / selectedIndexs.count)"
            } else {
                cell.accessoryType = .none
                memberCell.selectedButton.isSelected = false
                memberCell.equalLabel.isHidden = true
                memberCell.percentLabel.isHidden = true
            }
            memberCell.priceTextField.isHidden = true
        } else if typePickerView.textField.text == SplitType.percent.label {
            if selectedIndexs.contains(indexPath.row) {
                memberCell.selectedButton.isSelected = true
                memberCell.priceTextField.isHidden = false
                memberCell.percentLabel.text = "%"
                memberCell.percentLabel.isHidden = false
            } else {
                cell.accessoryType = .none
                memberCell.selectedButton.isSelected = false
                memberCell.priceTextField.isHidden = true
                memberCell.percentLabel.isHidden = true
            }
            memberCell.equalLabel.isHidden = true
        } else if typePickerView.textField.text == SplitType.customize.label {
            if selectedIndexs.contains(indexPath.row) {
                memberCell.selectedButton.isSelected = true
                memberCell.priceTextField.isHidden = false
                memberCell.percentLabel.text = "元"
                memberCell.percentLabel.isHidden = false
            } else {
                cell.accessoryType = .none
                memberCell.selectedButton.isSelected = false
                memberCell.priceTextField.isHidden = true
                memberCell.percentLabel.isHidden = true
            }
            memberCell.equalLabel.isHidden = true
//            memberCell.percentLabel.isHidden = true
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
            involvedMemberName.append(memberData?[indexPath.row].userName ?? "")
            
            let involedExpense = ExpenseInfo(userId: memberData?[indexPath.row].userId ?? "", price: 0)
            involvedExpenseData.append(involedExpense)
        }
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension AddItemViewController: AddItemTableViewCellDelegate {
    func endEditing(_ cell: AddItemTableViewCell) {
        
        involvedPrice = Double(cell.priceTextField.text ?? "0")
        
        let name = cell.memberName.text
        let selectedUser = memberData?.filter { $0.userName == name }
        guard let id = selectedUser?[0].userId else { return }
                
        for index in 0..<involvedExpenseData.count {
            
            if involvedExpenseData[index].userId == id {
                involvedExpenseData[index].price = involvedPrice ?? 0
            }
        }
    }
}
