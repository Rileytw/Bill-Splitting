//
//  SubscribeViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/17.
//

import UIKit

class SubscribeViewController: UIViewController {
    
    let currentUserId = AccountManager.shared.currentUser.currentUserId
    var startTimeDatePicker = UIDatePicker()
    var endTimeDatePicker = UIDatePicker()
    
    var startDate: Date?
    var endDate: Date?
    var month: Int?
    var createdTimeTimeStamps = [Double]()
    
    var startTimeLabel = UILabel()
    var endTimeLabel = UILabel()
    var cycleLabel = UILabel()
    var completeButton = UIButton()
    
    var cyclePicker = BasePickerViewInTextField(frame: .zero)
    var cycle = ["每月", "每年"]
    
    let addItemView = AddItemView(frame: .zero)
    let tableView = UITableView()
    var selectedIndexs = [Int]()
    var documentId: String?
    var paidItem: [[ExpenseInfo]] = []
    var involvedItem: [[ExpenseInfo]] = []
    var paidId: String?
    var paidPrice: Double?
    var involvedExpenseData: [ExpenseInfo] = []
    var involvedPrice: Double?
    var involvedMemberName: [String] = []
    
    var groupData: GroupData?
    var memberId: [String]?
    var memberData: [UserData]? = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLabel()
        setDatePicker()
        setCyclePicker()
        setCompleteButton()
        setAddItemView()
        setTableView()
    }
    
    func setLabel() {
        view.addSubview(startTimeLabel)
        startTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        startTimeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        startTimeLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        startTimeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        startTimeLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        startTimeLabel.text = "開始時間"
        startTimeLabel.font = startTimeLabel.font.withSize(16)
        
        view.addSubview(endTimeLabel)
        endTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        endTimeLabel.topAnchor.constraint(equalTo: startTimeLabel.bottomAnchor, constant: 20).isActive = true
        endTimeLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        endTimeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        endTimeLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        endTimeLabel.text = "結束時間"
//        endTimeLabel.font = endTimeLabel.font.withSize(16)
        
        view.addSubview(cycleLabel)
        cycleLabel.translatesAutoresizingMaskIntoConstraints = false
        cycleLabel.topAnchor.constraint(equalTo: endTimeLabel.bottomAnchor, constant: 20).isActive = true
        cycleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        cycleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        cycleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        cycleLabel.text = "週期"
        cycleLabel.font = endTimeLabel.font.withSize(16)
        
    }
    
    func setDatePicker() {
        view.addSubview(startTimeDatePicker)
        startTimeDatePicker.translatesAutoresizingMaskIntoConstraints = false
        startTimeDatePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        startTimeDatePicker.heightAnchor.constraint(equalToConstant: 40).isActive = true
        startTimeDatePicker.leadingAnchor.constraint(equalTo: startTimeLabel.trailingAnchor, constant: 10).isActive = true
        startTimeDatePicker.widthAnchor.constraint(equalToConstant: 180).isActive = true
        
        startTimeDatePicker.datePickerMode = UIDatePicker.Mode.date
        startTimeDatePicker.locale = Locale(identifier: "zh_Hant_TW")
        startTimeDatePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)

        view.addSubview(endTimeDatePicker)
        endTimeDatePicker.translatesAutoresizingMaskIntoConstraints = false
        endTimeDatePicker.topAnchor.constraint(equalTo: startTimeLabel.bottomAnchor, constant: 20).isActive = true
        endTimeDatePicker.heightAnchor.constraint(equalToConstant: 40).isActive = true
        endTimeDatePicker.leadingAnchor.constraint(equalTo: endTimeLabel.trailingAnchor, constant: 10).isActive = true
        endTimeDatePicker.widthAnchor.constraint(equalToConstant: 180).isActive = true
        endTimeDatePicker.datePickerMode = UIDatePicker.Mode.date
        endTimeDatePicker.locale = Locale(identifier: "zh_Hant_TW")
        endTimeDatePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
    }
    
    func setCyclePicker() {
        view.addSubview(cyclePicker)
        cyclePicker.translatesAutoresizingMaskIntoConstraints = false
        cyclePicker.topAnchor.constraint(equalTo: cycleLabel.bottomAnchor, constant: 0).isActive = true
        cyclePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        cyclePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        cyclePicker.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        cyclePicker.pickerView.dataSource = self
        cyclePicker.pickerView.delegate = self
    }
    
    func setCompleteButton() {
        view.addSubview(completeButton)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        completeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        completeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        completeButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        completeButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        completeButton.setTitle("設定", for: .normal)
        completeButton.backgroundColor = .systemTeal
        completeButton.addTarget(self, action: #selector(pressCompleteButton), for: .touchUpInside)
    }
    
    @objc func pressCompleteButton() {
        countSubscriptiontime()
        updateSubscriptionData()
        self.dismiss(animated: true, completion: nil)
    }
    
    func setAddItemView() {
        view.addSubview(addItemView)
        addItemView.translatesAutoresizingMaskIntoConstraints = false
        addItemView.topAnchor.constraint(equalTo: cyclePicker.bottomAnchor, constant: 10).isActive = true
        addItemView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        addItemView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        addItemView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        addItemView.itemName.text = "項目名稱"
        addItemView.priceLabel.text = "支出金額"
    }
    
    func setTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: addItemView.bottomAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: completeButton.topAnchor, constant: 10).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        tableView.register(UINib(nibName: String(describing: AddItemTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: AddItemTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @objc func datePickerChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if sender == startTimeDatePicker {
            startDate = startTimeDatePicker.date
            print("startDate: \(startDate)")
        } else if sender == endTimeDatePicker {
            endDate = endTimeDatePicker.date
            print("endDate: \(endDate)")
        }
        let components = Calendar.current.dateComponents([.month], from: startDate ?? Date(), to: endDate ?? Date())
        month = components.month
        print("Number of months: \(month)")
        countSubscriptiontime()
    }
    
    func countSubscriptiontime() {
        var monthOfsubscription = 0
        var dateArray = [Date]()
        while monthOfsubscription <= month ?? 0 {
            var dateComponent = DateComponents()
            dateComponent.month = monthOfsubscription
            let adjustedDate = Calendar.current.date(byAdding: dateComponent, to: startDate ?? Date())
            dateArray.append(adjustedDate ?? Date())
            createdTimeTimeStamps = dateArray.map { $0.timeIntervalSince1970 }
            
            monthOfsubscription += 1
        }
        print("dateArray: \(dateArray)")
        print("timeStamp: \(createdTimeTimeStamps)")
    }
    
    func updateSubscriptionData() {
        paidPrice = Double(self.addItemView.priceTextField.text ?? "0")
        let startTimeStamp = startDate?.timeIntervalSince1970
        let endTimeStamp = endDate?.timeIntervalSince1970
        let nowTimeStamp = Date().timeIntervalSince1970
        
// MARK: cycle is fake data(0: Month, 1: Year)
        var cycleNumber: Int?
        if cyclePicker.textField.text == Cycle.month.rawValue {
            cycleNumber = 0
        } else if cyclePicker.textField.text == Cycle.year.rawValue {
            cycleNumber = 1
        }
        guard let cycleNumber = cycleNumber else { return }
        SubscriptionManager.shared.addSubscriptionData(groupId: groupData?.groupId ?? "",
                                                       itemName: addItemView.itemNameTextField.text ?? "",
                                                       paidUser: currentUserId,
                                                       paidPrice: paidPrice ?? 0,
                                                       startedTime: startTimeStamp ?? nowTimeStamp,
                                                       endedTime: endTimeStamp ?? nowTimeStamp,
                                                       cycle: cycleNumber) { [weak self] documentId in
            let involvedPerson = self?.involvedExpenseData.count ?? 0
            for user in 0..<involvedPerson {
                SubscriptionManager.shared.addSubscriptionInvolvedExpense(
                    involvedUserId: self?.involvedExpenseData[user].userId ?? "",
                    price: self?.involvedExpenseData[user].price ?? 0,
                    documentId: documentId)
            }
        }
    }
}

extension SubscribeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cycle.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cycle[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        return cyclePicker.textField.text = cycle[row]
    }
}

extension SubscribeViewController: UITableViewDataSource, UITableViewDelegate {
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
        } else {
            selectedIndexs.append(indexPath.row)
            involvedMemberName.append(memberData?[indexPath.row].userName ?? "")
            
            let involedExpense = ExpenseInfo(userId: memberData?[indexPath.row].userId ?? "", price: 0)
            involvedExpenseData.append(involedExpense)
        }
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension SubscribeViewController: AddItemTableViewCellDelegate {
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
