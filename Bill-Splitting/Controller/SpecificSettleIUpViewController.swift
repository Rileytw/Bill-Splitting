//
//  SpecificSettleIUpViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/17.
//

import UIKit

class SpecificSettleIUpViewController: UIViewController {

    var userData: UserData?
//    var expense: Double
    var memberExpense: MemberExpense?
    
    var nameLabel = UILabel()
    var price = UILabel()
    var account = UILabel()
    var settleButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print("userData:\(userData)")
//        print("memberExpense:\(memberExpense)")
        setUserInfo()
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
        } else {
            nameLabel.text = "收款對象：\(userData.userName)"
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
        } else {
            price.text = "收款金額：\(abs(memberExpense.allExpense)) 元"
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

}
