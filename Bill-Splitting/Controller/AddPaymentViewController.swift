//
//  AddPaymentViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/19.
//

import UIKit

class AddPaymentViewController: UIViewController {

// MARK: - Property
    let addItemView = AddItemView(frame: .zero)
    let linkLabel = UILabel()
    let linkTextView = UITextView()
    let saveButton = UIButton()
    
    var paymentName: String?
    var account: String?
    var link: String?

// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        setAddItemView()
        setLink()
        setSaveButton()
        setDismissButton()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        ElementsStyle.styleTextField(addItemView.itemNameTextField)
        ElementsStyle.styleTextField(addItemView.priceTextField)
    }

// MARK: - Method
    @objc func pressSaveButton() {
        paymentName = addItemView.itemNameTextField.text
        account = addItemView.priceTextField.text
        link = linkTextView.text
        
        if addItemView.itemNameTextField.text == "" {
            loseInfoAlert(message: "請填寫收款方式")
        } else if addItemView.priceTextField.text == "" {
            loseInfoAlert(message: "請填寫帳戶")
        } else {
            UserManager.shared.addPaymentData(paymentName: paymentName, account: account, link: link)
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func pressDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loseInfoAlert(message: String) {
        let alertController = UIAlertController(title: "請填寫完整資訊", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "確認", style: .default, handler: nil)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func setAddItemView() {
        view.addSubview(addItemView)
        addItemView.translatesAutoresizingMaskIntoConstraints = false
        addItemView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70).isActive = true
        addItemView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        addItemView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        addItemView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        addItemView.itemName.text = "收款方式"

        addItemView.itemNameTextField.attributedPlaceholder = NSAttributedString(string: "如：銀行(台新、國泰）、LinePay",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        addItemView.priceLabel.text = "帳戶"
        addItemView.priceTextField.attributedPlaceholder = NSAttributedString(string: "(XXX)00000000XXX000",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
    }
    
    func setLink() {
        view.addSubview(linkLabel)
        linkLabel.translatesAutoresizingMaskIntoConstraints = false
        linkLabel.topAnchor.constraint(equalTo: addItemView.bottomAnchor, constant: 20).isActive = true
        linkLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        linkLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 20).isActive = true
        linkLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        linkLabel.text = "請填入帳戶超連結"
        linkLabel.textColor = .greenWhite
        
        view.addSubview(linkTextView)
        linkTextView.translatesAutoresizingMaskIntoConstraints = false
        linkTextView.topAnchor.constraint(equalTo: linkLabel.bottomAnchor, constant: 20).isActive = true
        linkTextView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        linkTextView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        linkTextView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        linkTextView.layer.borderWidth = 1
        linkTextView.layer.borderColor = UIColor.selectedColor.cgColor
        linkTextView.backgroundColor = .clear
        linkTextView.textColor = UIColor.greenWhite
        linkTextView.font = UIFont.systemFont(ofSize: 16)
        linkTextView.layer.cornerRadius = 10
        linkTextView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 0)
    }
    
    func setSaveButton() {
        view.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        saveButton.setTitle("儲存", for: .normal)
        saveButton.backgroundColor = .greenWhite
        ElementsStyle.styleSpecificButton(saveButton)
        saveButton.addTarget(self, action: #selector(pressSaveButton), for: .touchUpInside)
    }
    
    func setDismissButton() {
        let dismissButton = UIButton()
        view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        dismissButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.tintColor = UIColor.greenWhite
        dismissButton.addTarget(self, action: #selector(pressDismiss), for: .touchUpInside)
    }
}
