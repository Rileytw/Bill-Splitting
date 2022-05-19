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
    var noDataView = NoDataView(frame: .zero)
    let tableView = UITableView()
    var userData: UserData?
    var userPayment: [Payment] = []
    var specificPayment: Payment? = Payment(paymentName: "", paymentAccount: "", paymentLink: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        setNoDataView()
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
//                guard let userPayment = userData?.payment else { return }
//                self?.userData = userData
//                self?.userPayment = userPayment
//                self?.tableView.reloadData()
                if let userPayment = userData?.payment {
                    self?.userData = userData
                    self?.userPayment = userPayment
                    self?.noDataView.noDataLabel.isHidden = true
                } else {
                    self?.noDataView.noDataLabel.isHidden = false
                }
                self?.tableView.reloadData()
            case .failure(let error):
                print("Error decoding userData: \(error)")
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showFailure(text: ErrorType.generalError.errorMessage)
            }
        }
    }
    
    func setNoDataView() {
        self.view.addSubview(noDataView)
        noDataView.noDataLabel.text = "尚未設定付款方式喔！"
        noDataView.translatesAutoresizingMaskIntoConstraints = false
        noDataView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        noDataView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        noDataView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        noDataView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func alertDeleteItem() {
        let alertController = UIAlertController(title: "刪除付款方式",
                                                message: "刪除後無法復原，請確認是否刪除",
                                                preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "刪除", style: .destructive) { [weak self]_ in
            self?.deletePayment()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func deletePayment() {
        UserManager.shared.deleteUserPayment(
            userId: currentUserId,
            paymentName: self.specificPayment?.paymentName,
            account: self.specificPayment?.paymentAccount,
            link: self.specificPayment?.paymentLink) { [weak self] result in
            switch result {
            case .success:
                print("delete")
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showSuccess(text: "刪除成功")

            case .failure(let error):
                print(error.localizedDescription)
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showFailure(text: "刪除失敗，請稍後再試")

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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completionHandler) in
            // delete the item here
//            ReminderManager.shared.deleteReminder(documentId: self.allReminders[indexPath.row].documentId)
//            self.allReminders.remove(at: indexPath.row)
//            self.tableView.deleteRows(at: [indexPath], with: .fade)
//            completionHandler(true)
            self?.specificPayment?.paymentName = self?.userPayment[indexPath.row].paymentName
            self?.specificPayment?.paymentAccount = self?.userPayment[indexPath.row].paymentAccount
            self?.specificPayment?.paymentLink = self?.userPayment[indexPath.row].paymentLink
            self?.alertDeleteItem()
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}
