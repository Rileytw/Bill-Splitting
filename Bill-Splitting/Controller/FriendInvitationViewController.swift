//
//  FriendInvitationViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/12.
//

import UIKit

class FriendInvitationViewController: UIViewController {
    
    let tableView = UITableView()
    
    var senderId: [String] = []
    var invitationUsers = [UserData]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserInfo()
    }
    
    func getSenderData(completion: @escaping ([String]) -> Void) {
        FriendManager.shared.fetchFriendInvitation(userId: userId) { result in
            switch result {
            case .success(let invitation):
                let senderId = invitation.map { $0.senderId }
                completion(senderId)
                print("senderId: \(senderId)")
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
    }
    
    func getUserInfo() {
        getSenderData() { senderIdList in
            print("senderList:\(senderIdList.count)")
            self.senderId = senderIdList
            
            self.senderId.forEach {
                sender in
                UserManager.shared.fetchUserData(friendId: sender) {
                    result in
                    switch result {
                    case .success(let userData):
                        self.invitationUsers.append(userData)
                        print("userData:\(userData)")
                        print("invitationData: \(self.invitationUsers)")
                    case .failure(let error):
                        print("Error decoding userData: \(error)")
                    }
                }
            }
        }
        
    }
    
    func setTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        tableView.register(UINib(nibName: String(describing: InvitationTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: InvitationTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension FriendInvitationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invitationUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: InvitationTableViewCell.self),
            for: indexPath
        )
        
        guard let invitationCell = cell as? InvitationTableViewCell else { return cell }
        
        invitationCell.nameLabel.text = invitationUsers[indexPath.row].userName
        
        return invitationCell
    }
}
