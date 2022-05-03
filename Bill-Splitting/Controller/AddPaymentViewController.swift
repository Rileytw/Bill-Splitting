//
//  AddPaymentViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/19.
//

import UIKit

class AddPaymentViewController: UIViewController {

    let addItemView = AddItemView(frame: .zero)
    let linkLabel = UILabel()
    let linkTextView = UITextView()
    let saveButton = UIButton()
    
    var paymentName: String?
    var account: String?
    var link: String?
    
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
    
    func setAddItemView() {
        view.addSubview(addItemView)
        addItemView.translatesAutoresizingMaskIntoConstraints = false
        addItemView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70).isActive = true
        addItemView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        addItemView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        addItemView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        addItemView.itemName.text = "收款方式"
        addItemView.itemNameTextField.placeholder = " 如：銀行(台新、國泰）、LinePay"
        addItemView.priceLabel.text = "帳戶號碼"
        addItemView.priceTextField.placeholder = "(XXX)00000000XXX000"
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
    
    @objc func pressSaveButton() {
        paymentName = addItemView.itemNameTextField.text
        account = addItemView.priceTextField.text
        link = linkTextView.text
        
        UserManager.shared.addPaymentData(paymentName: paymentName, account: account, link: link)
        dismiss(animated: true, completion: nil)
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
    
    @objc func pressDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}
