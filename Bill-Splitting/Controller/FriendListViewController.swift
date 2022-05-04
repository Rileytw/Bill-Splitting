//
//  FriendListViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/12.
//

import UIKit

class FriendListViewController: UIViewController {

    let currentUserId = AccountManager.shared.currentUser.currentUserId
    let tableView = UITableView()
    let width = UIScreen.main.bounds.size.width
    let height = UIScreen.main.bounds.size.height
    var blockUserView = BlockUserView()
    var mask = UIView()
    var blockedUserId: String?
    
    var friends: [Friend]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        setInviteButton()
        setTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        fetchFriends()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    func setInviteButton() {
        let inviteFriendButton = UIButton()
        inviteFriendButton.setTitle("邀請好友", for: .normal)
        inviteFriendButton.setImage(UIImage(systemName: "plus"), for: .normal)
        inviteFriendButton.tintColor = .greenWhite
        inviteFriendButton.setTitleColor(.greenWhite, for: .normal)
        ElementsStyle.styleSpecificButton(inviteFriendButton)
        view.addSubview(inviteFriendButton)
        inviteFriendButton.translatesAutoresizingMaskIntoConstraints = false
        inviteFriendButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        inviteFriendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        inviteFriendButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        inviteFriendButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        
        inviteFriendButton.addTarget(self, action: #selector(pressInviteFriendButton), for: .touchUpInside)
    }
    
    @objc func pressInviteFriendButton() {
        let storyBoard = UIStoryboard(name: "AddGroups", bundle: nil)
        let inviteFriendViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: InviteFriendViewController.self))
        self.present(inviteFriendViewController, animated: true, completion: nil)
    }

    func setTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.backgroundColor = .clear
        
        tableView.register(UINib(nibName: String(describing: FriendListTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: FriendListTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func fetchFriends() {
        UserManager.shared.fetchFriendData(userId: currentUserId) { [weak self] result in
            switch result {
            case .success(let friend):
                self?.friends = friend
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
    }
}

extension FriendListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: FriendListTableViewCell.self),
            for: indexPath
        )
        
        guard let profileCell = cell as? FriendListTableViewCell else { return cell }
        
        profileCell.createCell(userName: friends?[indexPath.row].userName ?? "",
                               userEmail: friends?[indexPath.row].userEmail ?? "")
        profileCell.infoButton.addTarget(self, action: #selector(pressMoreInfo), for: .touchUpInside)
        
        return profileCell
    }
    
    @objc func pressMoreInfo(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: point) {
            self.blockedUserId = friends?[indexPath.row].userId
        }
        
        revealBlockView()
    }
    
    func revealBlockView() {
        mask = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        mask.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        view.addSubview(mask)
        
        blockUserView = BlockUserView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 300))
        blockUserView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.blockUserView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height -  self.view.safeAreaInsets.bottom - 300, width: UIScreen.main.bounds.size.width, height: 300)
        }, completion: nil)
        view.addSubview(blockUserView)
        
        blockUserView.blockUserButton.addTarget(self, action: #selector(blockUserAlert), for: .touchUpInside)
        
        blockUserView.dismissButton.addTarget(self, action: #selector(pressDismissButton), for: .touchUpInside)
    }
    
    @objc func pressDismissButton() {
//        blockUserView.removeFromSuperview()
        let subviewCount = self.view.subviews.count
        
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.view.subviews[subviewCount - 1].frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        }, completion: nil)
        mask.removeFromSuperview()
    }
    
    @objc func blockUserAlert() {
        let alertController = UIAlertController(title: "請確認是否封鎖使用者", message: "封鎖後不可解除", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "封鎖", style: .destructive) { [weak self] _ in
            print("封鎖\(self?.blockedUserId)")
            self?.blockUser()
            self?.addToBlackList()
            
            self?.pressDismissButton()
            self?.navigationController?.popToRootViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func blockUser() {
        FriendManager.shared.removeFriend(userId: currentUserId, friendId: blockedUserId ?? "") { result in
            switch result {
            case .success():
                print("remove friend successfully")
            case .failure(let error):
                print("\(error.localizedDescription)")
            }
        }
    }
    
    func addToBlackList() {
        FriendManager.shared.addBlockFriends(userId: currentUserId, blockedUser: blockedUserId ?? "") { result in
            switch result {
            case .success():
                print("Add blackList successfully")
            case .failure(let error):
                print("\(error.localizedDescription)")
            }
        }
    }
}
