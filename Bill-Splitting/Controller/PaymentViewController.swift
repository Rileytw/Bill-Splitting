//
//  PaymentViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/19.
//

import UIKit

class PaymentViewController: UIViewController {

    let currentUserId = AccountManager.shared.currentUser.currentUserId
    let addPaymentButton = UIButton()
    let tableView = UITableView()
    var userData: UserData?
    var userPayment: [Payment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        setTableView()
        setAddButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        getUserPayment()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        addPaymentButton.layer.cornerRadius = 0.5 * addPaymentButton.bounds.size.width
        addPaymentButton.clipsToBounds = true
    }
    
    func setAddButton() {
        view.addSubview(addPaymentButton)
        addPaymentButton.translatesAutoresizingMaskIntoConstraints = false
        addPaymentButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        addPaymentButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        addPaymentButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        addPaymentButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        addPaymentButton.backgroundColor = .systemTeal
        addPaymentButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addPaymentButton.tintColor = .white
        ElementsStyle.styleSpecificButton(addPaymentButton)
        addPaymentButton.addTarget(self, action: #selector(addPayment), for: .touchUpInside)
    }
    
    @objc func addPayment() {
        let storyBoard = UIStoryboard(name: "Profile", bundle: nil)
        let addPaymentViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: AddPaymentViewController.self))
        self.present(addPaymentViewController, animated: true, completion: nil)
    }
    
    func setTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.backgroundColor = .clear
        
        tableView.register(UINib(nibName: String(describing: PaymentTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: PaymentTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func getUserPayment() {
        UserManager.shared.fetchUserData(friendId: currentUserId) { [weak self] result in
            switch result {
            case .success(let userData):
                guard let userPayment = userData.payment else { return }
                self?.userData = userData
                self?.userPayment = userPayment
//                print("userData:\(userData)")
//                print("userPayment:\(self?.userPayment)")
                self?.tableView.reloadData()
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
    }
}

extension PaymentViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userPayment.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: PaymentTableViewCell.self),
            for: indexPath
        )
        
        guard let paymentCell = cell as? PaymentTableViewCell else { return cell }
        
        paymentCell.createPaymentCell(payment: userPayment[indexPath.row].paymentName ?? "",
                                      accountName: userPayment[indexPath.row].paymentAccount ?? "",
                                      link: userPayment[indexPath.row].paymentLink ?? "")

        return paymentCell
    }
}
