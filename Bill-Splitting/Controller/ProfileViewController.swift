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
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ProfileTableViewCell.self),
            for: indexPath
        )
        
        guard let profileCell = cell as? ProfileTableViewCell else { return cell }
        
        if indexPath.row == 0 {
            profileCell.profileItemName.text = "QRCode"
        } else if indexPath.row == 1 {
            profileCell.profileItemName.text = "設定付款方式"
        } else if indexPath.row == 2 {
            profileCell.profileItemName.text = "朋友列表"
        } else  if indexPath.row == 3 {
            profileCell.profileItemName.text = "朋友邀請"
        } else {
            profileCell.profileItemName.text = "登出"
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
        } else {
            logOut()
        }
    }
}
