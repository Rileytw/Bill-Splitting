//
//  SignUpViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/26.
//

import UIKit
import Firebase
import FirebaseAuth
import Lottie

class SignUpViewController: UIViewController {

    private var animationView = AnimationView()
    var userNameTextField = UITextField()
    var emailTextField = UITextField()
    var passwordTextField = UITextField()
    var validPasswordTextField = UITextField()
    var signUpButton = UIButton()
    var userData = UserData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        setNameTextField()
        setEmailTextField()
        setPasswordTextField()
        setValidPasswordTextField()
        setSignUpButton()
        setDismissButton()
        }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        ElementsStyle.styleTextField(userNameTextField)
        ElementsStyle.styleTextField(emailTextField)
        ElementsStyle.styleTextField(passwordTextField)
        ElementsStyle.styleTextField(validPasswordTextField)
    }
    
    func setNameTextField() {
        view.addSubview(userNameTextField)
        userNameTextField.translatesAutoresizingMaskIntoConstraints = false
        setNameTextFieldConstraint()
        userNameTextField.attributedPlaceholder = NSAttributedString(string: "輸入姓名",
                                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
    }

    func setEmailTextField() {
        view.addSubview(emailTextField)
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        setEmailTextFieldConstraint()
        emailTextField.attributedPlaceholder = NSAttributedString(string: "輸入信箱",
                                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
    }

    func setPasswordTextField() {
        view.addSubview(passwordTextField)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        setPasswordTextFieldConstraint()
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "輸入密碼",
                                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
    }
    
    func setValidPasswordTextField() {
        view.addSubview(validPasswordTextField)
        validPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        setValidTextFieldConstraint()
        validPasswordTextField.attributedPlaceholder = NSAttributedString(string: "再次輸入密碼",
                                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
    }
    
    func setSignUpButton() {
        view.addSubview(signUpButton)
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        setSignUpconstraint()
        signUpButton.setTitle("註冊", for: .normal)
        signUpButton.setTitleColor(.greenWhite, for: .normal)
        ElementsStyle.styleSpecificButton(signUpButton)
        signUpButton.layer.cornerRadius = 8.0
        signUpButton.addTarget(self, action: #selector(pressSignUp), for: .touchUpInside)
    }
    
    @objc func pressSignUp() {
        checkUserInput()
    }
    
    func signUpWithFirebase() {
        AccountManager.shared.signUpWithFireBase(email: emailTextField.text ?? "",
                                                password: passwordTextField.text ?? "") { [weak self] result in
            switch result {
            case .success(let firebaseId):
                self?.userData.userName = self?.userNameTextField.text ?? ""
                self?.userData.userEmail = firebaseId.userEmail
                self?.userData.userId = firebaseId.userId
                self?.uploadUserData()
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showSuccess(text: "註冊成功")
            case .failure(let error):
                if let errorCode = AuthErrorCode(rawValue: error._code) {
                    ProgressHUD.shared.view = self?.view ?? UIView()
                    ProgressHUD.showFailure(text: errorCode.errorMessage)
                    self?.removeAnimation()
                }
                
            }
        }
    }
    
    func uploadUserData() {
        UserManager.shared.addUserData(userData: userData) {  [weak self] result in
            switch result {
            case .success:
                self?.dismiss(animated: true, completion: nil)
            case .failure(let error):
                print("Error decoding userData: \(error)")
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showFailure(text: ErrorType.generalError.errorMessage)
            }
            self?.removeAnimation()
        }
    }
    
    func checkUserInput() {
        if userNameTextField.text == "" {
            inputAlert(title: "尚未填寫姓名",
                       message: "請寫姓名再進行註冊")
        } else if emailTextField.text == "" {
            inputAlert(title: "尚未填寫 email",
                       message: "請寫 email 再進行註冊")
        } else if passwordTextField.text == "" {
            inputAlert(title: "尚未填寫密碼",
                       message: "請寫密碼再進行註冊")
        } else if validPasswordTextField.text == "" {
            inputAlert(title: "尚未確認密碼",
                       message: "請確認密碼再進行註冊")
        } else if validPasswordTextField.text != passwordTextField.text {
            inputAlert(title: "密碼驗證錯誤",
                       message: "請重新確認密碼再進行註冊")
        } else {
            setAnimation()
            signUpWithFirebase()
        }
    }
    
    func inputAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "確認", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func setEmailTextFieldConstraint() {
        emailTextField.topAnchor.constraint(equalTo: userNameTextField.bottomAnchor, constant: 20).isActive = true
        emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setPasswordTextFieldConstraint() {
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        passwordTextField.isSecureTextEntry = true
    }
    
    func setSignUpconstraint() {
        signUpButton.topAnchor.constraint(equalTo: validPasswordTextField.bottomAnchor, constant: 60).isActive = true
        signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        signUpButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
        signUpButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setNameTextFieldConstraint() {
        userNameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        userNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        userNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        userNameTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    func setValidTextFieldConstraint() {
        validPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20).isActive = true
        validPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        validPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        validPasswordTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        validPasswordTextField.isSecureTextEntry = true
    }
    
    func setDismissButton() {
        let dismissButton = UIButton()
        view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.tintColor = UIColor.greenWhite
        dismissButton.addTarget(self, action: #selector(pressDismiss), for: .touchUpInside)
    }
    
    @objc func pressDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setAnimation() {
        animationView = .init(name: "accountLoading")
        view.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        animationView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        animationView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.75
        animationView.play()
    }
    
    func removeAnimation() {
        animationView.stop()
        animationView.removeFromSuperview()
    }
}
