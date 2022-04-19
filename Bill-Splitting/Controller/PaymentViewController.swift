//
//  PaymentViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/19.
//

import UIKit

class PaymentViewController: UIViewController {

    let addPaymentButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAddButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
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
        addPaymentButton.addTarget(self, action: #selector(addPayment), for: .touchUpInside)
    }
    
    @objc func addPayment() {
        let storyBoard = UIStoryboard(name: "Profile", bundle: nil)
        let addPaymentViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: AddPaymentViewController.self))
        self.present(addPaymentViewController, animated: true, completion: nil)
    }
}
