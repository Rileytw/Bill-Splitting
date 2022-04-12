//
//  ProfileViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/12.
//

import UIKit

class ProfileViewController: UIViewController {
    
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableView()
        
    }
    
    func setTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        tableView.register(UINib(nibName: String(describing: ProfileTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ProfileTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ProfileTableViewCell.self),
            for: indexPath
        )
        
        guard let profileCell = cell as? ProfileTableViewCell else { return cell }
        
        if indexPath.row == 0 {
            profileCell.profileItemName.text = "朋友列表"
        } else {
            profileCell.profileItemName.text = "朋友邀請"
        }
        
        return profileCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let storyBoard = UIStoryboard(name: "Profile", bundle: nil)
            let friendListViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: FriendListViewController.self))
            self.present(friendListViewController, animated: true, completion: nil)
        }
    }
}
