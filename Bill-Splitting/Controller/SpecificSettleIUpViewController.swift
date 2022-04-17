//
//  SpecificSettleIUpViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/17.
//

import UIKit

class SpecificSettleIUpViewController: UIViewController {
    
    var userData: UserData?
    var groupId: String?
    var memberExpense: MemberExpense?
    var itemId: String?
    
    var nameLabel = UILabel()
    var price = UILabel()
    var account = UILabel()
    var settleButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        print("userData:\(userData)")
        //        print("memberExpense:\(memberExpense)")
        setUserInfo()
        setSettleUpButton()
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
        guard let memberExpense = memberExpense,
              let userData = userData
        else { return }
        
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 40).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        if memberExpense.allExpense >= 0 {
            nameLabel.text = "匯款對象：\(userData.userName)"
            nameLabel.textColor = .systemPink
        } else {
            nameLabel.text = "收款對象：\(userData.userName)"
            nameLabel.textColor = .systemTeal
        }
        
        nameLabel.font = nameLabel.font.withSize(24)
        
        view.addSubview(price)
        price.translatesAutoresizingMaskIntoConstraints = false
        price.topAnchor.constraint(equalTo: nameLabel.topAnchor, constant: 60).isActive = true
        price.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        price.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 40).isActive = true
        price.heightAnchor.constraint(equalToConstant: 40).isActive = true
        if memberExpense.allExpense >= 0 {
            price.text = "匯款金額：\(abs(memberExpense.allExpense)) 元"
            price.textColor = .systemPink
        } else {
            price.text = "收款金額：\(abs(memberExpense.allExpense)) 元"
            price.textColor = .systemTeal
        }
        
        price.font = price.font.withSize(24)
        
        view.addSubview(account)
        account.translatesAutoresizingMaskIntoConstraints = false
        account.topAnchor.constraint(equalTo: price.topAnchor, constant: 60).isActive = true
        account.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        account.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 40).isActive = true
        account.heightAnchor.constraint(equalToConstant: 40).isActive = true
        account.text = "帳戶資訊"
        account.font = price.font.withSize(20)
    }
    
    func setSettleUpButton() {
        view.addSubview(settleButton)
        settleButton.translatesAutoresizingMaskIntoConstraints = false
        settleButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        settleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        settleButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        settleButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        settleButton.setTitle("已結清", for: .normal)
        settleButton.backgroundColor = .systemGray
        settleButton.addTarget(self, action: #selector(pressSettleUpButton), for: .touchUpInside)
    }
    
    @objc func pressSettleUpButton() {
        addItem()
        
        if let groupViewController = self.navigationController?.viewControllers[1] {
            self.navigationController?.popToViewController(groupViewController, animated: true)
        }
    }
    
    func addItem() {
        guard let expense = memberExpense?.allExpense,
              let memberId = memberExpense?.userId
        else { return }
        
        ItemManager.shared.addItemData(groupId: groupId ?? "",
                                       itemName: "結帳",
                                       itemDescription: "",
                                       createdTime: Double(NSDate().timeIntervalSince1970)) {
            itemId in
            self.itemId = itemId
            
            var paidUserId: String?
            var creditorId: String?
            
            if expense <= 0 {
                paidUserId = userId
                creditorId = memberId
            } else {
                paidUserId = memberId
                creditorId = userId
            }
            
            ItemManager.shared.addPaidInfo(paidUserId: paidUserId ?? "",
                                           price: expense,
                                           itemId: itemId,
                                           createdTime: Double(NSDate().timeIntervalSince1970))
            
            ItemManager.shared.addInvolvedInfo(involvedUserId: creditorId ?? "",
                                               price: expense,
                                               itemId: itemId,
                                               createdTime: Double(NSDate().timeIntervalSince1970))
            
            self.updatePersonalExpense()
        }
    }
    
    func updatePersonalExpense() {
        guard let expense = memberExpense?.allExpense,
              let memberId = memberExpense?.userId
        else { return }
        
        var paidUserId: String?
        var creditorId: String?
        
        if expense <= 0 {
            paidUserId = userId
            creditorId = memberId
        } else {
            paidUserId = memberId
            creditorId = userId
        }
        
        GroupManager.shared.updateMemberExpense(userId: paidUserId ?? "",
                                                newExpense: expense,
                                                groupId: groupId ?? "")
        
        GroupManager.shared.updateMemberExpense(userId: creditorId ?? "",
                                                newExpense: 0 - expense,
                                                groupId: groupId ?? "")
    }
}
