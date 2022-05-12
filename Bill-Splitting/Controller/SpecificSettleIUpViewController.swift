//
//  SpecificSettleIUpViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/17.
//

import UIKit

class SpecificSettleIUpViewController: UIViewController {
    
    let currentUserId = AccountManager.shared.currentUser.currentUserId
    var userData: UserData?
    var groupId: String?
    var groupData: GroupData?
    var memberExpense: MemberExpense?
    var itemId: String?
    var userExpense: [MemberExpense] = []
    
    var nameLabel = UILabel()
    var price = UILabel()
    var account = UILabel()
    var settleButton = UIButton()
    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        setUserInfo()
        setSettleUpButton()
        setTableView()
        networkDetect()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    func setUserInfo() {
        setNameInfo()
        setPriceInfo()
        
        view.addSubview(account)
        account.translatesAutoresizingMaskIntoConstraints = false
        account.topAnchor.constraint(equalTo: price.topAnchor, constant: 60).isActive = true
        account.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        account.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40).isActive = true
        account.heightAnchor.constraint(equalToConstant: 40).isActive = true
        account.text = "帳戶資訊"
        account.font = price.font.withSize(20)
        account.textColor = UIColor.greenWhite
    }
    
    func setTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: account.bottomAnchor, constant: 10).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        tableView.bottomAnchor.constraint(equalTo: settleButton.topAnchor, constant: -10).isActive = true
        
        tableView.register(UINib(nibName: String(describing: PaymentTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: PaymentTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
    }
    
    func setSettleUpButton() {
        view.addSubview(settleButton)
        settleButton.translatesAutoresizingMaskIntoConstraints = false
        settleButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        settleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        settleButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        settleButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        settleButton.setTitle("已結清", for: .normal)
        ElementsStyle.styleSpecificButton(settleButton)
        settleButton.addTarget(self, action: #selector(pressSettleUpButton), for: .touchUpInside)
    }
    
    @objc func pressSettleUpButton() {
        if NetworkStatus.shared.isConnected == true {
            addItem()
            
            if let groupViewController = self.navigationController?.viewControllers[1] {
                self.navigationController?.popToViewController(groupViewController, animated: true)
            }
        } else {
            print("======== Cannot add groups")
            networkConnectAlert()
        }
    }
    
    func addItem() {
        guard let expense = memberExpense?.allExpense,
              let memberId = memberExpense?.userId
        else { return }
        
        let userExpense = userExpense.filter { $0.userId == currentUserId }
        
        ItemManager.shared.addItemData(groupId: groupId ?? "",
                                       itemName: "結帳",
                                       itemDescription: "",
                                       createdTime: Double(NSDate().timeIntervalSince1970),
                                       itemImage: nil) { itemId in
            self.itemId = itemId
            
            var paidUserId: String?
            var creditorId: String?
            if self.groupData?.creator == self.currentUserId {
                if expense <= 0 {
                    paidUserId = memberId
                    creditorId = self.currentUserId
                } else {
                    paidUserId = self.currentUserId
                    creditorId = memberId
                }
                
                ItemManager.shared.addPaidInfo(paidUserId: paidUserId ?? "",
                                               price: abs(expense),
                                               itemId: itemId,
                                               createdTime: Double(NSDate().timeIntervalSince1970)) { result in
                    switch result {
                    case .success:
                        print("success")
                    case .failure(let error):
                        print(error)
                    }
                }
                
                ItemManager.shared.addInvolvedInfo(involvedUserId: creditorId ?? "",
                                                   price: abs(expense),
                                                   itemId: itemId,
                                                   createdTime: Double(NSDate().timeIntervalSince1970)) { result in
                    switch result {
                    case .success:
                        print("success")
                    case .failure(let error):
                        print(error)
                    }
                }
            } else {
                if userExpense[0].allExpense <= 0 {
                    paidUserId = self.userData?.userId
                    creditorId = self.currentUserId
                } else {
                    paidUserId = self.currentUserId
                    creditorId = self.userData?.userId
                }
                
                ItemManager.shared.addPaidInfo(paidUserId: creditorId ?? "",
                                               price: abs(userExpense[0].allExpense),
                                               itemId: itemId,
                                               createdTime: Double(NSDate().timeIntervalSince1970)) { result in
                    switch result {
                    case .success:
                        print("success")
                    case .failure(let error):
                        print(error)
                    }
                }
                
                ItemManager.shared.addInvolvedInfo(involvedUserId: paidUserId ?? "",
                                                   price: abs(userExpense[0].allExpense),
                                                   itemId: itemId,
                                                   createdTime: Double(NSDate().timeIntervalSince1970)) { result in
                    switch result {
                    case .success:
                        print("success")
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            self.updatePersonalExpense()
        }
    }
    
    func updatePersonalExpense() {
        guard let expense = memberExpense?.allExpense,
              let memberId = memberExpense?.userId
        else { return }
        
        var paidUserId: String?
        var creditorId: String?
        
        let userExpense = userExpense.filter { $0.userId == currentUserId }
        
        if groupData?.creator == currentUserId {
            if expense <= 0 {
                paidUserId = currentUserId
                creditorId = memberId
                GroupManager.shared.updateMemberExpense(userId: paidUserId ?? "",
                                                        newExpense: expense,
                                                        groupId: groupId ?? "") { result in
                    switch result {
                    case .success:
                        print("success")
                    case .failure(let error):
                        print(error)
                    }
                }
                
                GroupManager.shared.updateMemberExpense(userId: creditorId ?? "",
                                                        newExpense: 0 - expense,
                                                        groupId: groupId ?? "") { result in
                    switch result {
                    case .success:
                        print("success")
                    case .failure(let error):
                        print(error)
                    }
                }
            } else {
                paidUserId = memberId
                creditorId = currentUserId
                GroupManager.shared.updateMemberExpense(userId: paidUserId ?? "",
                                                        newExpense: 0 - expense,
                                                        groupId: groupId ?? "") { result in
                    switch result {
                    case .success:
                        print("success")
                    case .failure(let error):
                        print(error)
                    }
                }
                
                GroupManager.shared.updateMemberExpense(userId: creditorId ?? "",
                                                        newExpense: expense,
                                                        groupId: groupId ?? "") { result in
                    switch result {
                    case .success:
                        print("success")
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        } else {
            if userExpense[0].allExpense <= 0 {
                paidUserId = currentUserId
                creditorId = userData?.userId
                GroupManager.shared.updateMemberExpense(userId: paidUserId ?? "",
                                                        newExpense: 0 - userExpense[0].allExpense,
                                                        groupId: groupId ?? "") { result in
                    switch result {
                    case .success:
                        print("success")
                    case .failure(let error):
                        print(error)
                    }
                }
                
                GroupManager.shared.updateMemberExpense(userId: creditorId ?? "",
                                                        newExpense: userExpense[0].allExpense,
                                                        groupId: groupId ?? "") { result in
                    switch result {
                    case .success:
                        print("success")
                    case .failure(let error):
                        print(error)
                    }
                }
            } else {
                paidUserId = userData?.userId
                creditorId = currentUserId
                GroupManager.shared.updateMemberExpense(userId: paidUserId ?? "",
                                                        newExpense: userExpense[0].allExpense,
                                                        groupId: groupId ?? "") { result in
                    switch result {
                    case .success:
                        print("success")
                    case .failure(let error):
                        print(error)
                    }
                }
                
                GroupManager.shared.updateMemberExpense(userId: creditorId ?? "",
                                                        newExpense: 0 - userExpense[0].allExpense,
                                                        groupId: groupId ?? "") { result in
                    switch result {
                    case .success:
                        print("success")
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
    
    func setNameInfo() {
        guard let memberExpense = memberExpense,
              let userData = userData
        else { return }
        
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        if memberExpense.allExpense >= 0 {
            if groupData?.creator == currentUserId {
                nameLabel.text = "付款對象：\(userData.userName)"
            } else {
                nameLabel.text = "收款對象：\(userData.userName)"
            }
        } else {
            if groupData?.creator == currentUserId {
                nameLabel.text = "收款對象：\(userData.userName)"
            } else {
                nameLabel.text = "付款對象：\(userData.userName)"
            }
        }
        nameLabel.font = nameLabel.font.withSize(20)
        nameLabel.textColor = .greenWhite
    }
    
    func setPriceInfo() {
        guard let memberExpense = memberExpense else { return }
        let userExpense = userExpense.filter { $0.userId == currentUserId }
        
        view.addSubview(price)
        price.translatesAutoresizingMaskIntoConstraints = false
        price.topAnchor.constraint(equalTo: nameLabel.topAnchor, constant: 60).isActive = true
        price.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        price.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40).isActive = true
        price.heightAnchor.constraint(equalToConstant: 40).isActive = true
        if memberExpense.allExpense >= 0 {
            if groupData?.creator == currentUserId {
                
                price.text = "付款金額：" + String(format: "%.2f", abs(memberExpense.allExpense)) + " 元"
            } else {
                price.text = "收款金額：" + String(format: "%.2f", abs(userExpense[0].allExpense)) + " 元"
            }

        } else {
            if groupData?.creator == currentUserId {
                price.text = "收款金額：" + String(format: "%.2f", abs(memberExpense.allExpense)) + " 元"
            } else {
                price.text = "付款金額：" + String(format: "%.2f", abs(userExpense[0].allExpense)) + " 元"
            }
        }
        price.font = price.font.withSize(20)
        price.textColor = .greenWhite
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
}

extension SpecificSettleIUpViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userData?.payment?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: PaymentTableViewCell.self),
            for: indexPath
        )
        
        guard let paymentCell = cell as? PaymentTableViewCell else { return cell }
        let userPayment = userData?.payment
        
        paymentCell.createPaymentCell(payment: userPayment?[indexPath.row].paymentName ?? "",
                                      accountName: userPayment?[indexPath.row].paymentAccount ?? "",
                                      link: userPayment?[indexPath.row].paymentLink ?? "")

        return paymentCell
    }
}
