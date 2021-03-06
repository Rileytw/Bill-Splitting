//
//  FriendListViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/12.
//

import UIKit

class FriendListViewController: UIViewController {
    
    // MARK: - Property
    let tableView = UITableView()
    var noDataView = NoDataView(frame: .zero)
    var blockUserView = BlockUserView()
    var blockUserViewBottom: NSLayoutConstraint?
    var mask = UIView()
    let currentUserId = UserManager.shared.currentUser?.userId ?? ""
    var blockedUserId: String?
    
    var friends: [Friend]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        setInviteButton()
        setNoDataView()
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
    
    // MARK: - Method
    @objc func pressInviteFriendButton() {
        let storyBoard = UIStoryboard(name: StoryboardCategory.addGroups, bundle: nil)
        let inviteFriendViewController = storyBoard.instantiateViewController(
            withIdentifier: InviteFriendViewController.identifier)
        if #available(iOS 15.0, *) {
            if let sheet = inviteFriendViewController.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.preferredCornerRadius = 20
            }
        }
        self.present(inviteFriendViewController, animated: true, completion: nil)
    }
    
    func fetchFriends() {
        UserManager.shared.fetchFriendData(userId: currentUserId) { [weak self] result in
            switch result {
            case .success(let friend):
                self?.friends = friend
                if friend.isEmpty == true {
                    self?.noDataView.noDataLabel.isHidden = false
                }
            case .failure:
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showFailure(text: ErrorType.generalError.errorMessage)
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
        mask.backgroundColor = .maskBackgroundColor
        view.stickSubView(mask)
        
        setBlockView()
        blockUserViewBottom?.constant = -300
        UIView.animate(
            withDuration: 0.25, delay: 0,
            options: UIView.AnimationOptions.curveEaseIn, animations: { [weak self] in
                self?.view.layoutIfNeeded()
            }, completion: nil)
        
        blockUserView.blockUserButton.addTarget(self, action: #selector(blockUserAlert), for: .touchUpInside)
        blockUserView.dismissButton.addTarget(self, action: #selector(pressDismissButton), for: .touchUpInside)
    }
    
    private func setBlockView() {
        blockUserView.removeFromSuperview()
        view.addSubview(blockUserView)
        blockUserView.translatesAutoresizingMaskIntoConstraints = false
        blockUserView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        blockUserView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        blockUserView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        blockUserViewBottom = blockUserView.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        blockUserViewBottom?.isActive = true
        blockUserView.backgroundColor = .viewDarkBackgroundColor
        blockUserView.buttonTitle = " 封鎖使用者"
        blockUserView.content = "封鎖使用者後，並不會隱藏你們共享的群組，若有需要可在結清帳務後退出群組。"
        blockUserView.blockUserButton.setImage(UIImage(
            systemName: "person.crop.circle.badge.exclam.fill"), for: .normal)
        view.layoutIfNeeded()
    }
    
    @objc func pressDismissButton() {
        blockUserViewBottom?.constant = 0
        UIView.animate(withDuration: 0.25, delay: 0,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: nil)
        mask.removeFromSuperview()
    }
    
    @objc func blockUserAlert() {
        let alertController = UIAlertController(title: "請確認是否封鎖使用者", message: "封鎖後不可解除", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "封鎖", style: .destructive) { [weak self] _ in
            self?.blockUser()
            self?.addToBlockList()
            
            self?.pressDismissButton()
            self?.navigationController?.popToRootViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func blockUser() {
        FriendManager.shared.removeFriend(userId: currentUserId, friendId: blockedUserId ?? "") { [weak self] result in
            if case .failure = result {
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showFailure(text: ErrorType.generalError.errorMessage)
            }
        }
        
        FriendManager.shared.removeFriend(userId: blockedUserId ?? "", friendId: currentUserId) { [weak self] result in
            if case .failure = result {
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showFailure(text: ErrorType.generalError.errorMessage)
            }
        }
    }
    
    func addToBlockList() {
        FriendManager.shared.addBlockFriends(userId: currentUserId,
                                             blockedUser: blockedUserId ?? "") { [weak self] result in
            if case .failure = result {
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showFailure(text: ErrorType.dataUpdateError.errorMessage)
            }
        }
    }
    
    func setNoDataView() {
        self.view.addSubview(noDataView)
        noDataView.noDataLabel.text = "目前還沒有好友，快邀請好友加入吧！"
        noDataView.translatesAutoresizingMaskIntoConstraints = false
        noDataView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60).isActive = true
        noDataView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        noDataView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        noDataView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
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
        inviteFriendButton.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        
        inviteFriendButton.addTarget(self, action: #selector(pressInviteFriendButton), for: .touchUpInside)
    }
    
    func setTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.backgroundColor = .clear
        
        tableView.register(UINib(nibName: String(describing: FriendListTableViewCell.self),
                                 bundle: nil),
                           forCellReuseIdentifier: String(describing: FriendListTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
    }
    
}
