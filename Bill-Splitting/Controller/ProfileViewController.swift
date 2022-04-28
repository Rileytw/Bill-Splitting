//
//  ProfileViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/12.
//

import UIKit
import Firebase
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    let tableView = UITableView()
    
   
    var profileList: [ProfileList] = [ProfileList.qrCode, ProfileList.payment, ProfileList.friendList, ProfileList.friendInvitation, ProfileList.logOut, ProfileList.deleteAccount]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableView()
        
        navigationItem.title = "個人頁面"
    }
    
    func setTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        tableView.register(UINib(nibName: String(describing: ProfileTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ProfileTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func logOut() {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let signInViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: SignInViewController.self))
                view.window?.rootViewController = signInViewController
                view.window?.makeKeyAndVisible()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func deletAccount() {
        UserManager.shared.deleteUserData(userId: userId) { result in
            switch result {
            case .success():
                AccountManager.shared.deleteAccount()
            case .failure(let error):
                print("Error updating document: \(error)")
                
            }
        }
    }
    
    func alertDeleteAccount() {
        let alertController = UIAlertController(title: "刪除帳號", message: "請確認是否刪除帳號", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "刪除", style: .destructive) { [weak self]_ in
            self?.deletAccount()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ProfileTableViewCell.self),
            for: indexPath
        )
        
        guard let profileCell = cell as? ProfileTableViewCell else { return cell }
        
        if indexPath.row == 0 {
            profileCell.profileItemName.text = ProfileList.qrCode.content
        } else if indexPath.row == 1 {
            profileCell.profileItemName.text = ProfileList.payment.content
        } else if indexPath.row == 2 {
            profileCell.profileItemName.text = ProfileList.friendList.content
        } else  if indexPath.row == 3 {
            profileCell.profileItemName.text = ProfileList.friendInvitation.content
        } else if indexPath.row == 4 {
            profileCell.profileItemName.text = ProfileList.logOut.content
        } else {
            profileCell.profileItemName.text = ProfileList.deleteAccount.content
        }
        
        return profileCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let storyBoard = UIStoryboard(name: "Profile", bundle: nil)
            let qrCodeViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: QRCodeViewController.self))
            self.show(qrCodeViewController, sender: nil)
        } else if indexPath.row == 1 {
            let storyBoard = UIStoryboard(name: "Profile", bundle: nil)
            let paymentViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: PaymentViewController.self))
            self.show(paymentViewController, sender: nil)
        } else if indexPath.row == 2 {
            let storyBoard = UIStoryboard(name: "Profile", bundle: nil)
            let friendListViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: FriendListViewController.self))
            self.show(friendListViewController, sender: nil)
        } else if indexPath.row == 3 {
            let storyBoard = UIStoryboard(name: "Profile", bundle: nil)
            let friendInvitationViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: FriendInvitationViewController.self))
            self.show(friendInvitationViewController, sender: nil)
        } else if indexPath.row == 4 {
            logOut()
        } else {
            alertDeleteAccount()
        }
    }
}

enum ProfileList {
    case qrCode
    case payment
    case friendList
    case friendInvitation
    case logOut
    case deleteAccount
    
    var content: String {
        switch self {
        case .qrCode:
            return "QRCode"
        case .payment:
            return "設定付款方式"
        case .friendList:
            return "好友列表"
        case .friendInvitation:
            return "交友邀請"
        case .logOut:
            return "登出"
        case .deleteAccount:
            return "刪除帳號"
        }
    }
}
