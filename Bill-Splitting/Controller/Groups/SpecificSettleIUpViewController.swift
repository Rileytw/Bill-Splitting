//
//  SpecificSettleIUpViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/17.
//

import UIKit
import SwiftUI

class SpecificSettleIUpViewController: BaseViewController {
    
    // MARK: - Property
    var nameLabel = UILabel()
    var price = UILabel()
    var account = UILabel()
    var settleButton = UIButton()
    var tableView = UITableView()
    
    let currentUserId = UserManager.shared.currentUser?.userId ?? ""
    var userData: UserData?
    var groupId: String?
    var groupData: GroupData?
    var memberExpense: MemberExpense?
    var itemId: String?
    var userExpense: [MemberExpense] = []
    
    // MARK: - Lifecycle
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
    
    // MARK: - Method
    @objc func pressSettleUpButton() {
        if NetworkStatus.shared.isConnected == true {
            addItem()
            if let groupViewController = self.navigationController?.viewControllers[1] {
                self.navigationController?.popToViewController(groupViewController, animated: true)
            }
        } else {
            networkConnectAlert()
        }
    }
    
    func addItem() {
        guard let expense = memberExpense?.allExpense,
              let memberId = memberExpense?.userId,
              let groupId = groupData?.groupId
        else { return }
        
        let userExpense = userExpense.filter { $0.userId == currentUserId }
        
        var item = ItemData()
        item.groupId = groupId
        item.itemName = "結帳"
        item.createdTime = Double(NSDate().timeIntervalSince1970)
        ItemManager.shared.addItemData(itemData: item) { itemId in
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
                
                AddItemManager.shared.addSettleUpItem(groupId: groupId, itemId: itemId,
                                                      paidUserId: paidUserId ?? "", paidPrice: abs(expense),
                                                      involvedUserId: creditorId ?? "",
                                                      involvedPrice: abs(expense)) { [weak self] in
                    if AddItemManager.shared.isDataUploadSucces {
                        self?.addItemNotification()
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
                
                AddItemManager.shared.addSettleUpItem(groupId: groupId, itemId: itemId,
                                                      paidUserId: creditorId ?? "", paidPrice: abs(userExpense[0].allExpense),
                                                      involvedUserId: paidUserId ?? "",
                                                      involvedPrice: abs(userExpense[0].allExpense)) {[weak self] in
                    if AddItemManager.shared.isDataUploadSucces {
                        self?.addItemNotification()
                    }
                }
            }
        }
    }
    
    func addItemNotification() {
        ItemManager.shared.addNotify(grpupId: self.groupData?.groupId ?? "") { result in
            switch result {
            case .success:
                print("uplaod notification collection successfully")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func networkConnectAlert() {
        confirmAlert(title: "網路未連線", message: "網路未連線，無法結清，請確認網路連線後再結清。")
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

extension SpecificSettleIUpViewController {
    func setUserInfo() {
        setNameInfo()
        setPriceInfo()
        
        view.addSubview(account)
        account.translatesAutoresizingMaskIntoConstraints = false
        account.topAnchor.constraint(equalTo: price.topAnchor, constant: 40).isActive = true
        account.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        account.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        account.heightAnchor.constraint(equalToConstant: 40).isActive = true
        account.text = "帳戶資訊"
        account.font = price.font.withSize(20)
        account.textColor = UIColor.greenWhite
    }
    
    func setTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: account.bottomAnchor, constant: 10).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        tableView.bottomAnchor.constraint(equalTo: settleButton.topAnchor, constant: -10).isActive = true
        
        tableView.register(UINib(nibName: String(describing: PaymentTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: PaymentTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
    }
    
    func setSettleUpButton() {
        view.addSubview(settleButton)
        settleButton.translatesAutoresizingMaskIntoConstraints = false
        settleButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        settleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        settleButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        settleButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        settleButton.setTitle("確認結清", for: .normal)
        ElementsStyle.styleSpecificButton(settleButton)
        settleButton.addTarget(self, action: #selector(pressSettleUpButton), for: .touchUpInside)
    }
    
    func setNameInfo() {
        guard let memberExpense = memberExpense,
              let userData = userData
        else { return }
        
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        if memberExpense.allExpense >= 0 {
            if groupData?.creator == currentUserId {
                nameLabel.text = SettleUpType.pay.settleUpUser + "\(userData.userName)"
            } else {
                nameLabel.text = SettleUpType.credit.settleUpUser + "\(userData.userName)"
            }
        } else {
            if groupData?.creator == currentUserId {
                nameLabel.text = SettleUpType.credit.settleUpUser + "\(userData.userName)"
            } else {
                nameLabel.text = SettleUpType.pay.settleUpUser + "\(userData.userName)"
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
        price.topAnchor.constraint(equalTo: nameLabel.topAnchor, constant: 40).isActive = true
        price.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        price.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        price.heightAnchor.constraint(equalToConstant: 40).isActive = true
        if memberExpense.allExpense >= 0 {
            if groupData?.creator == currentUserId {
                price.text = SettleUpType.pay.settleUpPrice + Double.formatString(
                    abs(memberExpense.allExpense)) + " 元"
            } else {
                price.text = SettleUpType.credit.settleUpPrice + Double.formatString(
                    abs(userExpense[0].allExpense)) + " 元"
            }
            
        } else {
            if groupData?.creator == currentUserId {
                price.text = SettleUpType.credit.settleUpPrice + Double.formatString(
                    abs(memberExpense.allExpense)) + " 元"
            } else {
                price.text = SettleUpType.pay.settleUpPrice + Double.formatString(
                    abs(userExpense[0].allExpense)) + " 元"
            }
        }
        price.font = price.font.withSize(20)
        price.textColor = .greenWhite
    }
    
    enum SettleUpType {
        case pay
        case credit
        
        var settleUpPrice: String {
            switch self {
            case .pay:
                return "付款金額："
            case .credit:
                return "收款金額："
            }
        }
        
        var settleUpUser: String {
            switch self {
            case .pay:
                return "付款對象："
            case .credit:
                return "收款對象："
            }
        }
    }
}
