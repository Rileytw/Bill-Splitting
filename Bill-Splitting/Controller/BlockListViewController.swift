//
//  BlackListViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/5.
//

import UIKit

class BlockListViewController: UIViewController {

    let tableView = UITableView()
    var blockList = UserManager.shared.currentUser?.blackList
    var blockUsers = [UserData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        setTableView()
        getUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    func getUserData() {
        UserManager.shared.fetchUsersData { [weak self] result in
            switch result {
            case .success(let users):
                guard let blackList = self?.blockList else { return }
                for blockedUser in blackList {
                    self?.blockUsers += users.filter { $0.userId == blockedUser }
                }
                self?.tableView.reloadData()
            case .failure(let error):
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showFailure(text: ErrorType.generalError.errorMessage)
            }
        }
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
}

extension BlockListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: FriendListTableViewCell.self),
            for: indexPath
        )
        
        guard let profileCell = cell as? FriendListTableViewCell else { return cell }
        
        profileCell.createCell(userName: blockUsers[indexPath.row].userName, userEmail: blockUsers[indexPath.row].userEmail)
        profileCell.infoButton.isHidden = true
        
        return profileCell
    }
}
