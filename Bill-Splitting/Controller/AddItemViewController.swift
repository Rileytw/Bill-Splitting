//
//  AddItemViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/14.
//

import UIKit

class AddItemViewController: UIViewController {

    let addItemView = AddItemView(frame: .zero)
    let typePickerView = BasePickerViewInTextField(frame: .zero)
    var typePickerViewData = ["平分", "按比例", "自訂"]
    var memberPickerView = BasePickerViewInTextField(frame: .zero)
    let addButton = UIButton()
    let tableView = UITableView()
    
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
    
    var selectedIndexs = [Int]()
    var involvedMemberName: [String] = []
    
    typealias AddItemColsure = (String) -> Void
    var addItemColsure: AddItemColsure?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setAddItemView()
        setTypePickerView()
        setmemberPickerView()
        setAddButton()
        setTableView()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        tabBarController?.tabBar.isHidden = true
//        navigationController?.setNavigationBarHidden(true, animated: animated)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
    
    func setAddItemView() {
        view.addSubview(addItemView)
        addItemView.translatesAutoresizingMaskIntoConstraints = false
        addItemView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        addItemView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        addItemView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        addItemView.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }

    func setTypePickerView() {
        view.addSubview(typePickerView)
        typePickerView.translatesAutoresizingMaskIntoConstraints = false
        typePickerView.topAnchor.constraint(equalTo: addItemView.bottomAnchor, constant: 20).isActive = true
        typePickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        typePickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        typePickerView.heightAnchor.constraint(equalToConstant: 100).isActive = true

        typePickerView.pickerView.dataSource = self
        typePickerView.pickerView.delegate = self
        typePickerView.textField.placeholder = "請選擇分帳方式"
        
        typePickerView.pickerView.tag = 0
    }
    
    func setmemberPickerView() {
        view.addSubview(memberPickerView)
        memberPickerView.translatesAutoresizingMaskIntoConstraints = false
        memberPickerView.topAnchor.constraint(equalTo: typePickerView.bottomAnchor, constant: 20).isActive = true
        memberPickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        memberPickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        memberPickerView.heightAnchor.constraint(equalToConstant: 100).isActive = true

        memberPickerView.pickerView.dataSource = self
        memberPickerView.pickerView.delegate = self
        memberPickerView.textField.placeholder = "請選擇付款人"
        
        memberPickerView.pickerView.tag = 1
        
        if groupData?.type == 0 {
            memberPickerView.isHidden = true
            memberPickerView.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }
    }
    
    func setAddButton() {
        view.addSubview(addButton)
        addButton.setTitle("完成", for: .normal)
        addButton.backgroundColor = .systemGray
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        addButton.addTarget(self, action: #selector(pressAddButton), for: .touchUpInside)
    }
    
    func setTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: memberPickerView.bottomAnchor, constant: 20).isActive = true
        tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: 10).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        tableView.register(UINib(nibName: String(describing: AddItemTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: AddItemTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @objc func pressAddButton() {
        ItemManager.shared.addItemData(groupId: groupData?.groupId ?? "",
                                       itemName: addItemView.itemNameTextField.text ?? "",
                                       itemDescription: "",
                                       createdTime: Double(NSDate().timeIntervalSince1970)) {
            itemId in
            self.itemId = itemId
            
            var paidUserId: String?
            if self.groupData?.type == 1 {
                paidUserId = self.paidId
            } else {
                paidUserId = userId
            }
            
            self.paidPrice = Double(self.addItemView.priceTextField.text ?? "0")
            
            ItemManager.shared.addPaidInfo(paidUserId: paidUserId ?? "",
                                           price: self.paidPrice ?? 0,
                                           itemId: itemId,
                                           createdTime: Double(NSDate().timeIntervalSince1970))

            for user in 0..<self.involvedExpenseData.count {
                ItemManager.shared.addInvolvedInfo(involvedUserId: self.involvedExpenseData[user].userId,
                                                   price: self.involvedExpenseData[user].price,
                                                   itemId: itemId,
                                                   createdTime: Double(NSDate().timeIntervalSince1970))
            }
            self.countPersonalExpense()
        }
        self.dismiss(animated: false, completion: nil)
//        navigationController?.popViewController(animated: true)
        addItemColsure?("id")
        
    }
    
    func countPersonalExpense() {
        
        var paidUserId: String?
        if self.groupData?.type == 1 {
            paidUserId = self.paidId
        } else {
            paidUserId = userId
        }
        
        GroupManager.shared.updateMemberExpense(userId: paidUserId ?? "",
                                                newExpense: self.paidPrice ?? 0,
                                                groupId: groupData?.groupId ?? "")
        
        for user in 0..<self.involvedExpenseData.count {
            GroupManager.shared.updateMemberExpense(userId: self.involvedExpenseData[user].userId,
                                                    newExpense: 0 - self.involvedExpenseData[user].price,
                                                    groupId: groupData?.groupId ?? "")
        }
    }
    
    func addItem(closure: @escaping AddItemColsure) {
        addItemColsure = closure
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
            return typePickerView.textField.text = typePickerViewData[row]
        } else {
            paidId = memberData?[row].userId
            paidPrice = Double(addItemView.priceTextField.text ?? "0")
//            print("paidId: \(paidId), paidPrice: \(paidPrice)")
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
        
        if selectedIndexs.contains(indexPath.row) {
            memberCell.selectedButton.isSelected = true
            memberCell.priceTextField.isHidden = false
        } else {
            cell.accessoryType = .none
            memberCell.selectedButton.isSelected = false
            memberCell.priceTextField.isHidden = true
        }
        
        memberCell.delegate = self
        
        return memberCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let index = selectedIndexs.index(of: indexPath.row) {
            selectedIndexs.remove(at: index)
            involvedMemberName.remove(at: index)
            involvedExpenseData.remove(at: index)
//            print("remove: \(involvedExpenseData)")
        } else {
            selectedIndexs.append(indexPath.row)
            involvedMemberName.append(memberData?[indexPath.row].userName ?? "")
            
            var involedExpense = ExpenseInfo(userId: memberData?[indexPath.row].userId ?? "", price: 0)
            involvedExpenseData.append(involedExpense)
//            print("price: \(involvedPrice)")
//            print("involvedData: \(involvedExpenseData)")
        }
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension AddItemViewController: AddItemTableViewCellDelegate {
    func endEditing(_ cell: AddItemTableViewCell) {
        
        involvedPrice = Double(cell.priceTextField.text ?? "0")
        
        let name = cell.memberName.text
        var selectedUser = memberData?.filter { $0.userName == name }
        guard let id = selectedUser?[0].userId else { return }
                
        for index in 0..<involvedExpenseData.count {
            
            if involvedExpenseData[index].userId == id {
                involvedExpenseData[index].price = involvedPrice ?? 0
//                print("involvedPrice:\(involvedPrice)")
            }
            
        }
//        print("involvedData = \(involvedExpenseData)")
    }
}
