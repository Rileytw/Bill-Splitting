//
//  FriendListViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/12.
//

import UIKit

class FriendListViewController: UIViewController {

    let tableView = UITableView()
    
    var friends: [Friend]? {
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
        
        UserManager.shared.fetchFriendData(userId: userId) { result in
            switch result {
            case .success(let friend):
                self.friends = friend
//                print("userData: \(self.friends)")
            case .failure(let error):
                print("Error decoding userData: \(error)")
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
        
        tableView.register(UINib(nibName: String(describing: ProfileTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ProfileTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        
    }
}

extension FriendListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ProfileTableViewCell.self),
            for: indexPath
        )
        
        guard let profileCell = cell as? ProfileTableViewCell else { return cell }
        
        profileCell.profileItemName.text = friends?[indexPath.row].userName
        
        return profileCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
