//
//  FriendInvitationViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/12.
//

import UIKit

class FriendInvitationViewController: UIViewController {
    
    // MARK: - Property
    let tableView = UITableView()
    var noDataView = NoDataView(frame: .zero)
    let currentUserId = UserManager.shared.currentUser?.userId ?? ""
    var currentUserName: String?
    var senderId: [String] = []
    var invitationUsers = [UserData]()
    var invitationId: [String] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        setNoDataView()
        setTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserInfo()
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Method
    func getSenderData(completion: @escaping ([String]) -> Void) {
        FriendManager.shared.fetchFriendInvitation(userId: currentUserId) { [weak self] result in
            switch result {
            case .success(let invitation):
                let senderId = invitation.map { $0.senderId }
                self?.invitationId = invitation.map { $0.documentId }
                completion(senderId)
            case .failure:
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showFailure(text: ErrorType.generalError.errorMessage)
            }
        }
    }
    
    func getUserInfo() {
        getSenderData { [weak self] senderIdList in
            self?.senderId = senderIdList
            if self?.senderId.isEmpty == true {
                self?.noDataView.noDataLabel.isHidden = false
            } else {
                self?.noDataView.noDataLabel.isHidden = true
            }
            
            self?.senderId.forEach { sender in
                UserManager.shared.fetchUserData(friendId: sender) { [weak self] result in
                    switch result {
                    case .success(let userData):
                        if let userData = userData {
                            self?.invitationUsers.append(userData)
                        }
                        self?.tableView.reloadData()
                    case .failure:
                        ProgressHUD.shared.view = self?.view ?? UIView()
                        ProgressHUD.showFailure(text: ErrorType.generalError.errorMessage)
                    }
                }
            }
        }
    }
    
    func setTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.backgroundColor = .clear
        
        tableView.register(UINib(
            nibName: String(describing: InvitationTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: InvitationTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setNoDataView() {
        self.view.addSubview(noDataView)
        noDataView.noDataLabel.text = "目前沒有好友邀請"
        noDataView.translatesAutoresizingMaskIntoConstraints = false
        noDataView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25).isActive = true
        noDataView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        noDataView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        noDataView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
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
        
        invitationCell.delegate = self
        
        invitationCell.nameLabel.text = invitationUsers[indexPath.row].userName
        invitationCell.email.text = invitationUsers[indexPath.row].userEmail
        
        return invitationCell
    }
}

extension FriendInvitationViewController: TableViewCellDelegate {
    func agreeInvitation(sender: InvitationTableViewCell) {
        guard let indexPath = tableView.indexPath(for: sender) else { return }
        FriendManager.shared.deleteFriendInvitation(documentId: invitationId[indexPath.row])
        
        FriendManager.shared.senderToFriends(userId: currentUserId, senderId: senderId[indexPath.row],
                                             senderName: invitationUsers[indexPath.row].userName,
                                             senderEmail: invitationUsers[indexPath.row].userEmail)
        
        FriendManager.shared.receiverToFriends(userId: currentUserId,
                                               senderId: senderId[indexPath.row],
                                               userName: currentUserName ?? "",
                                               userEmail: UserManager.shared.currentUser?.userEmail ?? "")
        
        self.invitationUsers.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .fade)
    }
    
    func disAgreeInvitation(sender: InvitationTableViewCell) {
        guard let indexPath = tableView.indexPath(for: sender) else { return }
        
        FriendManager.shared.deleteFriendInvitation(documentId: invitationId[indexPath.row])
        
        self.invitationUsers.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .fade)
        
    }
}
