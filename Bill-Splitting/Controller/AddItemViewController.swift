//
//  AddItemViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/14.
//

import UIKit
import Lottie

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
    
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    private var animationView = AnimationView()
    let mask = UIView()
    
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
    var involvedTotalPrice: Double = 0
    
    var itemImage: UIImage?
//    var imageUrl: String?
    
    var blackList = [String]()
    typealias EditItem = (String) -> Void
    var editingItem: EditItem?
    
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
        detectBlackListUser()
        networkDetect()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
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
        
        addItemView.priceTextField.keyboardType = .numberPad
        
        if isItemExist == true {
            addItemView.itemNameTextField.text = itemData?.itemName
            addItemView.priceTextField.text = String(itemData?.paidInfo?[0].price ?? 0)
        }
    }
    
    func setTypePickerView() {
        view.addSubview(typePickerView)
        typePickerView.translatesAutoresizingMaskIntoConstraints = false
        typePickerView.topAnchor.constraint(equalTo: addItemView.bottomAnchor, constant: 20).isActive = true
        typePickerView.leadingAnchor.constraint(equalTo: typeLabel.trailingAnchor, constant: 10).isActive = true
        typePickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        typePickerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        typePickerView.pickerViewData = typePickerViewData
        
        typePickerView.pickerView.dataSource = self
        typePickerView.pickerView.delegate = self
        typePickerView.textField.delegate = self
        
        typePickerView.pickerView.tag = 0
    }
    
    func setmemberPickerView() {
        view.addSubview(choosePaidMember)
        choosePaidMember.translatesAutoresizingMaskIntoConstraints = false
        choosePaidMember.topAnchor.constraint(equalTo: typePickerView.bottomAnchor, constant: 20).isActive = true
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
        memberPickerView.topAnchor.constraint(equalTo: typePickerView.bottomAnchor, constant: 20).isActive = true
        memberPickerView.leadingAnchor.constraint(equalTo: choosePaidMember.trailingAnchor, constant: 20).isActive = true
        memberPickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        memberPickerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        memberPickerView.pickerView.dataSource = self
        memberPickerView.pickerView.delegate = self
        memberPickerView.textField.delegate = self
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
        addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        ElementsStyle.styleSpecificButton(addButton)
        
        addButton.addTarget(self, action: #selector(pressAddButton), for: .touchUpInside)
    }
    
    func setAddMoreButton() {
        view.addSubview(addMoreButton)
        addMoreButton.translatesAutoresizingMaskIntoConstraints = false
        addMoreButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        addMoreButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        addMoreButton.widthAnchor.constraint(equalToConstant: 180).isActive = true
        addMoreButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        addMoreButton.backgroundColor = .systemTeal
        addMoreButton.setImage(UIImage(systemName: "paperclip"), for: .normal)
        addMoreButton.setTitle("新增照片及說明", for: .normal)
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
        
        addMoreInfoViewController.itemImage = { [weak self] photo in
            self?.itemImage = photo
            
        }
        
        self.present(addMoreInfoViewController, animated: true, completion: nil)
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
    
    @objc func pressAddButton() {
        if NetworkStatus.shared.isConnected == true {
            checkInvolvedData()
            if addItemView.itemNameTextField.text == "" ||
                addItemView.priceTextField.text == "" ||
                typePickerView.textField.text == "" {
                lossInfoAlert(message: "請確認是否填寫款項名稱、支出金額並選擇分款方式")
            } else if memberPickerView.textField.text == "" && groupData?.type == GroupType.multipleUsers.typeInt {
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
            print("======== Cannot add groups")
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
    
    func checkInvolvedData() {
        involvedTotalPrice = 0
        for involvePrice in involvedExpenseData {
            involvedTotalPrice += involvePrice.price
        }
    }
    
    func lossInfoAlert(message: String) {
        let alertController = UIAlertController(title: "請填寫完整資訊", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "確認", style: .default, handler: nil)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func addItem() {
        ItemManager.shared.addItemData(groupId: groupData?.groupId ?? "",
                                       itemName: addItemView.itemNameTextField.text ?? "",
                                       itemDescription: itemDescription,
                                       createdTime: Double(NSDate().timeIntervalSince1970),
                                       itemImage: self.itemImageString) { [weak self] itemId in
            self?.itemId = itemId
            self?.allItemInfoUpload()
        }
    }
    
    func allItemInfoUpload() {
        var paidUserId: String?
        if self.groupData?.type == 1 {
            paidUserId = self.paidId
        } else {
            paidUserId = self.currentUserId
        }
        self.paidPrice = Double(self.addItemView.priceTextField.text ?? "0")
        let paidPrice = self.paidPrice
        var isDataUploadSucces: Bool = false
        
        let group = DispatchGroup()
        let firstQueue = DispatchQueue(label: "firstQueue", qos: .default, attributes: .concurrent)
        group.enter()

        firstQueue.async(group: group) {
            ItemManager.shared.addPaidInfo(paidUserId: paidUserId ?? "", price: paidPrice ?? 0, itemId: self.itemId ?? "",
                createdTime: Double(NSDate().timeIntervalSince1970)) { result in
                switch result {
                case .success:
                    print("success")
                    isDataUploadSucces = true
                    group.leave()
                case .failure(let error):
                    print(error)
                    isDataUploadSucces = false
                    group.leave()
                }
            }
        }

        let secondQueue = DispatchQueue(label: "secondQueue", qos: .default, attributes: .concurrent)
        for user in 0..<self.involvedExpenseData.count {
            var involvedPrice: Double?
            if self.typePickerView.textField.text == SplitType.equal.label {
                involvedPrice = Double(paidPrice ?? 0) / Double(self.selectedIndexs.count)
            } else if self.typePickerView.textField.text == SplitType.percent.label {
                involvedPrice = (Double(self.involvedExpenseData[user].price)/100.00) * Double(paidPrice ?? 0)
            } else {
                involvedPrice = self.involvedExpenseData[user].price
            }
            group.enter()
            secondQueue.async(group: group) {
                ItemManager.shared.addInvolvedInfo(involvedUserId: self.involvedExpenseData[user].userId,
                                                   price: involvedPrice ?? 0, itemId: self.itemId ?? "", createdTime: Double(NSDate().timeIntervalSince1970)) { result in
                    switch result {
                    case .success:
                        print("succedd")
                        isDataUploadSucces = true
                        group.leave()
                    case .failure(let error):
                        print(error)
                        isDataUploadSucces = false
                        group.leave()
                    }
                }
            }
        }

        let thirdQueue = DispatchQueue(label: "thirdQueue", qos: .default, attributes: .concurrent)
        group.enter()
        thirdQueue.async(group: group) {
            GroupManager.shared.updateMemberExpense(userId: paidUserId ?? "", newExpense: self.paidPrice ?? 0, groupId: self.groupData?.groupId ?? "") { result in
                switch result {
                case .success:
                    print("succedd")
                    isDataUploadSucces = true
                    group.leave()
                case .failure(let error):
                    print(error)
                    isDataUploadSucces = false
                    group.leave()
                }
            }
        }
        for user in 0..<self.involvedExpenseData.count {
            var involvedPrice: Double?
            if self.typePickerView.textField.text == SplitType.equal.label {
                involvedPrice = Double(paidPrice ?? 0) / Double(self.selectedIndexs.count)
            } else if self.typePickerView.textField.text == SplitType.percent.label {
                involvedPrice = (Double(self.involvedExpenseData[user].price)/100.00) * Double(paidPrice ?? 0)
            } else {
                involvedPrice = self.involvedExpenseData[user].price
            }
            guard let involvedPrice = involvedPrice else { return }

            let fourthQueue = DispatchQueue(label: "fourthQueue", qos: .default, attributes: .concurrent)
            group.enter()
            fourthQueue.async(group: group) {
                GroupManager.shared.updateMemberExpense(userId: self.involvedExpenseData[user].userId,
                                                        newExpense: 0 - involvedPrice, groupId: self.groupData?.groupId ?? "") { result in
                    switch result {
                    case .success:
                        print("succedd")
                        isDataUploadSucces = true
                        group.leave()
                    case .failure(let error):
                        print(error)
                        isDataUploadSucces = false
                        group.leave()
                    }
                }
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            if isDataUploadSucces == true {
                self.removeAnimation()
                ProgressHUD.shared.view = self.view ?? UIView()
                ProgressHUD.showSuccess(text: "新增成功")
                if self.isItemExist == true {
                    self.editingItem?(self.itemId ?? "")
                }
                
                ItemManager.shared.addNotify(grpupId: self.groupData?.groupId ?? "") { result in
                    switch result {
                    case .success:
                        print("uplaod notification collection successfully")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
                self.dismiss(animated: false, completion: nil)
            } else {
                self.removeAnimation()
                ProgressHUD.shared.view = self.view ?? UIView()
                ProgressHUD.showFailure(text: "發生錯誤，請稍後再試")
                self.dismiss(animated: false, completion: nil)
            }
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
        guard let paidUserId = itemData?.paidInfo?[0].userId,
              let paidPrice = itemData?.paidInfo?[0].price
        else { return }
        
        GroupManager.shared.updateMemberExpense(userId: paidUserId ,
                                                newExpense: 0 - paidPrice,
                                                groupId: groupData?.groupId ?? "") { result in
            switch result {
            case .success:
                print("succedd")
            case .failure(let error):
                print("error")
            }
        }
        
        guard let involvedExpense = itemData?.involedInfo else { return }
        
        for user in 0..<involvedExpense.count {
            GroupManager.shared.updateMemberExpense(userId: involvedExpense[user].userId,
                                                    newExpense: involvedExpense[user].price,
                                                    groupId: groupData?.groupId ?? "") { result in
                switch result {
                case .success:
                    print("succedd")
                case .failure(let error):
                    print("error")
                }
            }
        }
    }
    
    func networkDetect() {
        NetworkStatus.shared.startMonitoring()
        NetworkStatus.shared.netStatusChangeHandler = {
            if NetworkStatus.shared.isConnected == true {
                print("connected")
            } else {
                print("Not connected")
                if !Thread.isMainThread {
                    DispatchQueue.main.async {
                        ProgressHUD.shared.view = self.view
                        ProgressHUD.showFailure(text: "網路未連線，請連線後再試")
                    }
                }
            }
        }
    }
    
    func networkConnectAlert() {
        let alertController = UIAlertController(title: "網路未連線", message: "網路未連線，無法新增群組資料，請確認網路連線後再新增群組。", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "確認", style: .cancel, handler: nil)

        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
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
        dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
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
    
    func detectBlackListUser() {
        let newUserData = UserManager.renameBlockedUser(blockList: blackList,
                                                        userData: memberData ?? [])
        memberData = newUserData
    }
    
    func setAnimation() {
        
        mask.frame = CGRect(x: 0, y: 0, width: width, height: height)
        mask.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        animationView = .init(name: "upload")
        animationView.frame = CGRect(x: width/2 - 75, y: height/2 - 75, width: 150, height: 150)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        view.addSubview(mask)
        view.addSubview(animationView)
        animationView.play()
    }
    
    func removeAnimation() {
        mask.removeFromSuperview()
        animationView.stop()
        animationView.removeFromSuperview()
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
//                memberCell.equalLabel.text = "\(100 / selectedIndexs.count)"
                
                let percent: Double = (100.00 / Double(selectedIndexs.count))
                print("percent\(percent)")
                memberCell.equalLabel.text = String(format: "%.2f", percent)
//                String(format: "%.2f", currentRatio)
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
