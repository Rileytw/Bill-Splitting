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
    
    let currentUserId = AccountManager.shared.currentUser.currentUserId
    var currentUser: UserData?
    let tableView = UITableView()
    var profileView = UIView()
    let userName = UILabel()
    let userEmail = UILabel()
    let editButton = UIButton()
    
    var profileList: [ProfileList] = [ProfileList.qrCode, ProfileList.payment, ProfileList.friendList, ProfileList.friendInvitation, ProfileList.logOut, ProfileList.deleteAccount]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserData()
        setProfileView()
        setTableView()
        
        navigationItem.title = "個人頁面"
    }
    
    func getUserData() {
        UserManager.shared.fetchSignInUserData(userId: currentUserId) { [weak self] result in
            switch result {
            case .success(let user):
                self?.currentUser = user
                self?.userName.text = user?.userName
                self?.userEmail.text = user?.userEmail
            case.failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func setTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: profileView.bottomAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        tableView.register(UINib(nibName: String(describing: ProfileTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ProfileTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setProfileView() {
        self.view.addSubview(profileView)
        profileView.translatesAutoresizingMaskIntoConstraints = false
        setProfileViewConstraint()
        
        profileView.addSubview(userName)
        userName.translatesAutoresizingMaskIntoConstraints = false
        userName.topAnchor.constraint(equalTo: profileView.topAnchor, constant: 20).isActive = true
        userName.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 20).isActive = true
        userName.widthAnchor.constraint(equalTo: profileView.widthAnchor, constant: -40).isActive = true
        userName.heightAnchor.constraint(equalToConstant: 30).isActive = true
        userName.tintColor = .systemGray
        
        profileView.addSubview(userEmail)
        userEmail.translatesAutoresizingMaskIntoConstraints = false
        userEmail.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 10).isActive = true
        userEmail.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 20).isActive = true
        userEmail.widthAnchor.constraint(equalTo: profileView.widthAnchor, constant: -40).isActive = true
        userEmail.heightAnchor.constraint(equalToConstant: 30).isActive = true
        userEmail.tintColor = .systemGray
        
        profileView.addSubview(editButton)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.topAnchor.constraint(equalTo: profileView.topAnchor, constant: 20).isActive = true
        editButton.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -20).isActive = true
        editButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        editButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        editButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        editButton.tintColor = .systemGray
        editButton.addTarget(self, action: #selector(pressEdit), for: .touchUpInside)
    }
    
    @objc func pressEdit() {
        let alertController = UIAlertController(title: "修改名稱", message: "請輸入使用者名稱", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "新名稱"
        }
        let renameAlert = UIAlertAction(title: "修改", style: .default) { [weak self] _ in
            self?.updateUserName(newUserName: alertController.textFields?[0].text ?? "")
//            print(alertController.textFields?[0].text)
        }
        let cancelAlert = UIAlertAction(title: "取消", style: .default, handler: nil)
        alertController.addAction(renameAlert)
        alertController.addAction(cancelAlert)
        present(alertController, animated: true, completion: nil)
    }
    
    func updateUserName(newUserName: String) {
        UserManager.shared.updateUserName(userId: currentUserId, userName: newUserName) { [weak self] result in
            switch result {
            case .success():
                print("userName update successfully")
                self?.getUserData()
            case .failure(_):
                print("userName update failed")
            }
        }
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
        UserManager.shared.deleteUserData(userId: currentUserId, userName: currentUser?.userName ?? "") { result in
            switch result {
            case .success():
                AccountManager.shared.deleteAccount() { [weak self] result in
                    switch result {
                    case .success():
                        print("Account successfully deleted ")
                    case .failure(_):
                        self?.alertSignInAgain()
                    }
                }
            case .failure(let error):
                print("Error updating document: \(error)")
            }
        }
    }
    
    func alertDeleteAccount() {
        let alertController = UIAlertController(title: "刪除帳號", message: "請確認是否刪除帳號。提醒：若刪除帳號，將刪除您的 email 及收款資訊，但不會刪除您在群組中的帳務資訊", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "刪除", style: .destructive) { [weak self]_ in
            self?.deletAccount()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func alertSignInAgain() {
        let alertController = UIAlertController(title: "重新登入", message: "若需刪除帳號，請重新登入", preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "確認", style: .default, handler: nil)
        
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func setProfileViewConstraint() {
        profileView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        profileView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        profileView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        profileView.heightAnchor.constraint(equalToConstant: 100).isActive = true
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
            guard let friendInvitationVC = storyBoard.instantiateViewController(withIdentifier: String(describing: FriendInvitationViewController.self)) as? FriendInvitationViewController
            else { return }
            friendInvitationVC.currentUserName = currentUser?.userName
            self.show(friendInvitationVC, sender: nil)
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
