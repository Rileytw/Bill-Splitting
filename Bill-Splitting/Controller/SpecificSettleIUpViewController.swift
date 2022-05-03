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
    
    typealias AddItemColsure = (String) -> Void
    var addItemColsure: AddItemColsure?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        setUserInfo()
        setSettleUpButton()
        setTableView()
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
//        settleButton.backgroundColor = .systemGray
        settleButton.addTarget(self, action: #selector(pressSettleUpButton), for: .touchUpInside)
    }
    
    @objc func pressSettleUpButton() {
        addItem()
        
        if let groupViewController = self.navigationController?.viewControllers[1] {
            self.navigationController?.popToViewController(groupViewController, animated: true)
        }
        addItemColsure?("id")
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
                    paidUserId = self.currentUserId
                    creditorId = memberId
                } else {
                    paidUserId = memberId
                    creditorId = self.currentUserId
                }
                
                ItemManager.shared.addPaidInfo(paidUserId: paidUserId ?? "",
                                               price: abs(expense),
                                               itemId: itemId,
                                               createdTime: Double(NSDate().timeIntervalSince1970))
                
                ItemManager.shared.addInvolvedInfo(involvedUserId: creditorId ?? "",
                                                   price: abs(expense),
                                                   itemId: itemId,
                                                   createdTime: Double(NSDate().timeIntervalSince1970))
            } else {
                if userExpense[0].allExpense <= 0 {
                    paidUserId = self.currentUserId
                    creditorId = memberId
                } else {
                    paidUserId = memberId
                    creditorId = self.currentUserId
                }
                
                ItemManager.shared.addPaidInfo(paidUserId: creditorId ?? "",
                                               price: abs(userExpense[0].allExpense),
                                               itemId: itemId,
                                               createdTime: Double(NSDate().timeIntervalSince1970))
                
                ItemManager.shared.addInvolvedInfo(involvedUserId: paidUserId ?? "",
                                                   price: abs(userExpense[0].allExpense),
                                                   itemId: itemId,
                                                   createdTime: Double(NSDate().timeIntervalSince1970))
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
                                                        groupId: groupId ?? "")
                
                GroupManager.shared.updateMemberExpense(userId: creditorId ?? "",
                                                        newExpense: 0 - expense,
                                                        groupId: groupId ?? "")
            } else {
                paidUserId = memberId
                creditorId = currentUserId
                GroupManager.shared.updateMemberExpense(userId: paidUserId ?? "",
                                                        newExpense: 0 - expense,
                                                        groupId: groupId ?? "")
                
                GroupManager.shared.updateMemberExpense(userId: creditorId ?? "",
                                                        newExpense: expense,
                                                        groupId: groupId ?? "")
            }
        } else {
            if userExpense[0].allExpense <= 0 {
                paidUserId = currentUserId
                creditorId = memberId
                GroupManager.shared.updateMemberExpense(userId: paidUserId ?? "",
                                                        newExpense: 0 - userExpense[0].allExpense,
                                                        groupId: groupId ?? "")
                
                GroupManager.shared.updateMemberExpense(userId: creditorId ?? "",
                                                        newExpense: userExpense[0].allExpense,
                                                        groupId: groupId ?? "")
            } else {
                paidUserId = memberId
                creditorId = currentUserId
                GroupManager.shared.updateMemberExpense(userId: paidUserId ?? "",
                                                        newExpense: userExpense[0].allExpense,
                                                        groupId: groupId ?? "")
                
                GroupManager.shared.updateMemberExpense(userId: creditorId ?? "",
                                                        newExpense: 0 - userExpense[0].allExpense,
                                                        groupId: groupId ?? "")
            }
        }
    }
    
    func addItem(closure: @escaping AddItemColsure) {
        addItemColsure = closure
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
            nameLabel.text = "付款對象：\(userData.userName)"
            nameLabel.textColor = UIColor.styleRed
        } else {
            nameLabel.text = "收款對象：\(userData.userName)"
            nameLabel.textColor = UIColor.styleGreen
        }
        nameLabel.font = nameLabel.font.withSize(20)
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
                price.text = "付款金額：\(abs(memberExpense.allExpense)) 元"
                
            } else {
                price.text = "付款金額：\(abs(userExpense[0].allExpense)) 元"
            }
            price.textColor = UIColor.styleRed
        } else {
            if groupData?.creator == currentUserId {
                price.text = "收款金額：\(abs(memberExpense.allExpense)) 元"
            } else {
                price.text = "收款金額：\(abs(userExpense[0].allExpense)) 元"
            }
            price.textColor = UIColor.styleGreen
        }
        price.font = price.font.withSize(20)
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
