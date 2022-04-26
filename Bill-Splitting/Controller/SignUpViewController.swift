//
//  SignUpViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/26.
//

import UIKit

class SignUpViewController: UIViewController {

    var userNameLabel = UILabel()
    var userNameTextField = UITextField()
    var emailLabel = UILabel()
    var passwordLabel = UILabel()
    var emailTextField = UITextField()
    var passwordTextField = UITextField()
    var validPasswiedLabel = UILabel()
    var validPasswordTextField = UITextField()
    var signUpButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setName()
        setNameTextField()
        setEmail()
        setEmailTextField()
        setPassword()
        setPasswordTextField()
        setValidPassword()
        setValidPasswordTextField()
        setSignUpButton()
    }
    
    func setName() {
        view.addSubview(userNameLabel)
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        setNameLabelConstraint()
        userNameLabel.text = "姓名"
    }
    
    func setNameTextField() {
        view.addSubview(userNameTextField)
        userNameTextField.translatesAutoresizingMaskIntoConstraints = false
        setNameTextFieldConstraint()
        userNameTextField.borderStyle = .roundedRect
        userNameTextField.layer.borderColor = UIColor.systemGray.cgColor
        userNameTextField.layer.borderWidth = 1
    }

    func setEmail() {
        view.addSubview(emailLabel)
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        setEmailLabelConstraint()
        emailLabel.text = "email"
    }
    
    func setEmailTextField() {
        view.addSubview(emailTextField)
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        setEmailTextFieldConstraint()
        emailTextField.borderStyle = .roundedRect
        emailTextField.layer.borderColor = UIColor.systemGray.cgColor
        emailTextField.layer.borderWidth = 1
    }
    
    func setPassword() {
        view.addSubview(passwordLabel)
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        setPassordLabelConstraint()
        passwordLabel.text = "密碼"
    }
    
    func setPasswordTextField() {
        view.addSubview(passwordTextField)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        setPasswordTextFieldConstraint()
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.layer.borderColor = UIColor.systemGray.cgColor
        passwordTextField.layer.borderWidth = 1
    }
    
    func setValidPassword() {
        view.addSubview(validPasswiedLabel)
        validPasswiedLabel.translatesAutoresizingMaskIntoConstraints = false
        setValidPassordConstraint()
        validPasswiedLabel.text = "驗證密碼"
    }
    
    func setValidPasswordTextField() {
        view.addSubview(validPasswordTextField)
        validPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        setValidTextFieldConstraint()
        validPasswordTextField.borderStyle = .roundedRect
        validPasswordTextField.layer.borderColor = UIColor.systemGray.cgColor
        validPasswordTextField.layer.borderWidth = 1
    }
    

    func setSignUpButton() {
        view.addSubview(signUpButton)
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        setSignUpconstraint()
        signUpButton.setTitle("沒有帳號嗎？開始註冊", for: .normal)
        signUpButton.setTitleColor(.systemGray, for: .normal)
        signUpButton.addTarget(self, action: #selector(pressSignUp), for: .touchUpInside)
    }
    
    @objc func pressSignUp() {

    }

    func setPassordLabelConstraint() {
        passwordLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20).isActive = true
        passwordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        passwordLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        passwordLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setEmailLabelConstraint() {
        emailLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 20).isActive = true
        emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        emailLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        emailLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setEmailTextFieldConstraint() {
        emailTextField.topAnchor.constraint(equalTo: userNameTextField.bottomAnchor, constant: 20).isActive = true
        emailTextField.leadingAnchor.constraint(equalTo: emailLabel.trailingAnchor, constant: 20).isActive = true
        emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setPasswordTextFieldConstraint() {
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: passwordLabel.trailingAnchor, constant: 20).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setSignUpconstraint() {
        signUpButton.topAnchor.constraint(equalTo: validPasswordTextField.bottomAnchor, constant: 20).isActive = true
        signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        signUpButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        signUpButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setNameLabelConstraint() {
        userNameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        userNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        userNameLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        userNameLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setNameTextFieldConstraint() {
        userNameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        userNameTextField.leadingAnchor.constraint(equalTo: userNameLabel.trailingAnchor, constant: 20).isActive = true
        userNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        userNameTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setValidPassordConstraint() {
        validPasswiedLabel.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 20).isActive = true
        validPasswiedLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        validPasswiedLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        validPasswiedLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setValidTextFieldConstraint() {
        validPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20).isActive = true
        validPasswordTextField.leadingAnchor.constraint(equalTo: validPasswiedLabel.trailingAnchor, constant: 20).isActive = true
        validPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        validPasswordTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}
