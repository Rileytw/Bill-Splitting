//
//  SignInViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/25.
//

import UIKit
import AuthenticationServices

class SignInViewController: UIViewController {
    
    let authorizationButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
    var user: UserData = UserData(appleId: nil, userId: "", userName: "", userEmail: "", group: nil, payment: nil)
    
    var accountLabel = UILabel()
    var passwordLabel = UILabel()
    var accountTextField = UITextField()
    var passwordTextField = UITextField()
    var logInButton = UIButton()
    var signUpButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAccount()
        setAccountTextField()
        setPassword()
        setPasswordTextField()
        setLoginButton()
        setAppleSignInButton()
        setSignUpButton()
    }
    
    func setAppleSignInButton() {
        view.addSubview(authorizationButton)
        authorizationButton.translatesAutoresizingMaskIntoConstraints = false
        setAuthorizationButtonConstraint()
        authorizationButton.cornerRadius = 8.0
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
    }
    
    @objc func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func setAccount() {
        view.addSubview(accountLabel)
        accountLabel.translatesAutoresizingMaskIntoConstraints = false
        setAccountLabelConstraint()
        accountLabel.text = "帳號"
    }
    
    func setAccountTextField() {
        view.addSubview(accountTextField)
        accountTextField.translatesAutoresizingMaskIntoConstraints = false
        setAccountTextFieldConstraint()
        accountTextField.borderStyle = .roundedRect
        accountTextField.layer.borderColor = UIColor.systemGray.cgColor
        accountTextField.layer.borderWidth = 1
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
    
    func setLoginButton() {
        view.addSubview(logInButton)
        logInButton.translatesAutoresizingMaskIntoConstraints = false
        setLoginButtonConstraint()
        logInButton.setTitle("登入", for: .normal)
        logInButton.backgroundColor = .white
        logInButton.setTitleColor(.systemGray, for: .normal)
        logInButton.layer.cornerRadius = 8.0
        logInButton.layer.borderWidth = 1
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
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let signUpViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: SignUpViewController.self)) as? SignUpViewController else { return }
        
        if #available(iOS 15.0, *) {
            if let sheet = signUpViewController.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.preferredCornerRadius = 20
            }
        }
        self.present(signUpViewController, animated: true, completion: nil)
    }

    func setPassordLabelConstraint() {
        passwordLabel.topAnchor.constraint(equalTo: accountLabel.bottomAnchor, constant: 20).isActive = true
        passwordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        passwordLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        passwordLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setAccountLabelConstraint() {
        accountLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 200).isActive = true
        accountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        accountLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        accountLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setAccountTextFieldConstraint() {
        accountTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 200).isActive = true
        accountTextField.leadingAnchor.constraint(equalTo: accountLabel.trailingAnchor, constant: 20).isActive = true
        accountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        accountTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setPasswordTextFieldConstraint() {
        passwordTextField.topAnchor.constraint(equalTo: accountTextField.bottomAnchor, constant: 20).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: passwordLabel.trailingAnchor, constant: 20).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setLoginButtonConstraint() {
        logInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20).isActive = true
        logInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        logInButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        logInButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setAuthorizationButtonConstraint() {
        authorizationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        authorizationButton.topAnchor.constraint(equalTo: logInButton.bottomAnchor, constant: 20).isActive = true
        authorizationButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        authorizationButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setSignUpconstraint() {
        signUpButton.topAnchor.constraint(equalTo: authorizationButton.bottomAnchor, constant: 20).isActive = true
        signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        signUpButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        signUpButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}

extension SignInViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }
        
        print("user: \(credential.user)")
        print("fullName: \(String(describing: credential.fullName))")
        print("Email: \(String(describing: credential.email))")
        print("realUserStatus: \(String(describing: credential.realUserStatus))")
        
        user.userName = "\(credential.fullName?.familyName)" + "\(credential.fullName?.givenName)"
        user.userEmail = "\(credential.email)"
        user.appleId = String(credential.user)
        UserManager.shared.addUserData(userData: user) { result in
            switch result {
            case .success(let id):
                self.user.userId = id
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
            
        }
        
        let tabBarViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: TabBarViewController.self)) as? UITabBarController
        view.window?.rootViewController = tabBarViewController
        view.window?.makeKeyAndVisible()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        switch (error) {
        case ASAuthorizationError.canceled:
            break
        case ASAuthorizationError.failed:
            break
        case ASAuthorizationError.invalidResponse:
            break
        case ASAuthorizationError.notHandled:
            break
        case ASAuthorizationError.unknown:
            break
        default:
            break
        }
        
        print("didCompleteWithError: \(error.localizedDescription)")
    }
}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
