//
//  SignInViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/25.
//

import UIKit
import AuthenticationServices
import Firebase
import FirebaseAuth
import CryptoKit
import Lottie

class SignInViewController: UIViewController {
    
    let authorizationButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
    var user: UserData = UserData(userId: "", userName: "", userEmail: "", group: nil, payment: nil)
    
    private var animationView = AnimationView()
    var accountLabel = UILabel()
    var passwordLabel = UILabel()
    var accountTextField = UITextField()
    var passwordTextField = UITextField()
    var logInButton = UIButton()
    var signUpButton = UIButton()
    var thirdPartyId: String?
    var appleId: String?
    
    fileprivate var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        setAccount()
        setAccountTextField()
        setPassword()
        setPasswordTextField()
        setLoginButton()
        setAppleSignInButton()
        setSignUpButton()
        checkUserSignIn()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        ElementsStyle.styleTextField(accountTextField)
        ElementsStyle.styleTextField(passwordTextField)
    }
    
    func setAppleSignInButton() {
        view.addSubview(authorizationButton)
        authorizationButton.translatesAutoresizingMaskIntoConstraints = false
        setAuthorizationButtonConstraint()
        authorizationButton.cornerRadius = 8.0
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
    }
    
    @objc func handleAuthorizationAppleIDButtonPress() {
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func checkUserSignIn() {
        if Auth.auth().currentUser != nil {
            enterFistPage()
        }
    }
    
    func setAccount() {
        view.addSubview(accountLabel)
        accountLabel.translatesAutoresizingMaskIntoConstraints = false
        setAccountLabelConstraint()
        accountLabel.text = "帳號"
        accountLabel.textColor = .greenWhite
    }
    
    func setAccountTextField() {
        view.addSubview(accountTextField)
        accountTextField.translatesAutoresizingMaskIntoConstraints = false
        setAccountTextFieldConstraint()
    }
    
    func setPassword() {
        view.addSubview(passwordLabel)
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        setPassordLabelConstraint()
        passwordLabel.text = "密碼"
        passwordLabel.textColor = .greenWhite
    }
    
    func setPasswordTextField() {
        view.addSubview(passwordTextField)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        setPasswordTextFieldConstraint()
    }
    
    func setLoginButton() {
        view.addSubview(logInButton)
        logInButton.translatesAutoresizingMaskIntoConstraints = false
        setLoginButtonConstraint()
        logInButton.setTitle("登入", for: .normal)
        logInButton.setTitleColor(.greenWhite, for: .normal)
        ElementsStyle.styleSpecificButton(logInButton)
        logInButton.layer.cornerRadius = 8.0
        logInButton.addTarget(self, action: #selector(pressLogin), for: .touchUpInside)
    }
    
    @objc func pressLogin() {
        checkUserInput()
    }
    
    func signInWithFirebase() {
        AccountManager.shared.signInWithFirebase(email: accountTextField.text ?? "",
                                                 password: passwordTextField.text ?? "") { [weak self] result in
            switch result {
            case .success(let firebaseId):
                self?.fetchUserData(userId: firebaseId, email: self?.accountTextField.text ?? "")
            case .failure(let error):
                if let errorCode = AuthErrorCode(rawValue: error._code) {
                    ProgressHUD.shared.view = self?.view ?? UIView()
                    ProgressHUD.showFailure(text: errorCode.errorMessage)
                    self?.removeAnimation()
                }
            }
        }
    }
    
    func fetchUserData(userId: String, email: String) {
        
        UserManager.shared.fetchSignInUserData(userId: userId) { [weak self] result in
            switch result {
            case .success(let user):
//                print(user)
                if user == nil {
                    self?.user.userId = userId
                    self?.user.userEmail = email
                    self?.addNewUserData()
                }
                self?.user.userName = user?.userName ?? ""
                self?.user.userEmail = user?.userEmail ?? ""
                self?.user.userId = user?.userId ?? ""
                print("Login successed!")
                AccountManager.shared.getCurrentUserInfo()
                self?.enterFistPage()
            case .failure(let error):
                print("Error decoding userData: \(error)")
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showFailure(text: "讀取資料失敗")
            }
        }
    }
    
    func setSignUpButton() {
        view.addSubview(signUpButton)
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        setSignUpconstraint()
        signUpButton.setTitle("沒有帳號嗎？開始註冊", for: .normal)
        signUpButton.setTitleColor(.greenWhite, for: .normal)
        signUpButton.addTarget(self, action: #selector(pressSignUp), for: .touchUpInside)
    }
    
    @objc func pressSignUp() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let signUpViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: SignUpViewController.self)) as? SignUpViewController else { return }
        self.present(signUpViewController, animated: true, completion: nil)
    }
    
    func enterFistPage() {
        let tabBarViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: TabBarViewController.self)) as? UITabBarController
        view.window?.rootViewController = tabBarViewController
        view.window?.makeKeyAndVisible()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while(remainingLength > 0) {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if (errorCode != errSecSuccess) {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if (remainingLength == 0) {
                    return
                }
                
                if (random < charset.count) {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        return hashString
    }
    
    func checkUserInput() {
        if accountTextField.text == "" {
            inputAlert(title: "尚未輸入帳號",
                       message: "請輸入帳號再進行登入")
        } else if passwordTextField.text == "" {
            inputAlert(title: "尚未輸入密碼",
                       message: "請輸入密碼再進行登入")
        } else {
            setAnimation()
            signInWithFirebase()
        }
    }
    
    func inputAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "確認", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
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
    
    func setPassordLabelConstraint() {
        passwordLabel.topAnchor.constraint(equalTo: accountLabel.bottomAnchor, constant: 20).isActive = true
        passwordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        passwordLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        passwordLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setAccountLabelConstraint() {
        accountLabel.topAnchor.constraint(equalTo: view.centerYAnchor, constant: -150).isActive = true
        accountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        accountLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        accountLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setAccountTextFieldConstraint() {
        accountTextField.topAnchor.constraint(equalTo: view.centerYAnchor, constant: -150).isActive = true
        accountTextField.leadingAnchor.constraint(equalTo: accountLabel.trailingAnchor, constant: 20).isActive = true
        accountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        accountTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setPasswordTextFieldConstraint() {
        passwordTextField.topAnchor.constraint(equalTo: accountTextField.bottomAnchor, constant: 20).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: passwordLabel.trailingAnchor, constant: 20).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        passwordTextField.isSecureTextEntry = true
    }
    
    func setLoginButtonConstraint() {
        logInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 60).isActive = true
        logInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        logInButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        logInButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setAuthorizationButtonConstraint() {
        authorizationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        authorizationButton.topAnchor.constraint(equalTo: logInButton.bottomAnchor, constant: 40).isActive = true
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
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        
        guard let nonce = currentNonce else { return }
        
        guard let appleIDToken = credential.identityToken else { return }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else { return}
        let appCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
        self.appleId = credential.user
        user.userName = "\(credential.fullName?.familyName ?? "")" + "\(credential.fullName?.givenName ?? "")"
        user.userEmail = "\(credential.email ?? "")"

        firebaseSignInWithApple(credential: appCredential)
    }
    
    func firebaseSignInWithApple(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { authResult, error in
            guard error == nil else { return }
            self.getFirebaseUserInfo()
        }
    }
    
    func getFirebaseUserInfo() {
        let currentUser = Auth.auth().currentUser
        guard let user = currentUser else { return }
        let uid = user.uid
        let email = user.email
        self.user.userId = uid
        self.user.userEmail = email ?? ""
        fetchUserData(userId: uid, email: email ?? "")
    }
    
    func addNewUserData() {
        UserManager.shared.addUserData(userData: user) { [weak self] result in
            switch result {
            case .success(let id):
                self?.enterFistPage()
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        switch (error) {
        case ASAuthorizationError.canceled:
            errorHandleWithAppleSignIn()
//            break
        case ASAuthorizationError.failed:
            errorHandleWithAppleSignIn()
//            break
        case ASAuthorizationError.invalidResponse:
            errorHandleWithAppleSignIn()
//            break
        case ASAuthorizationError.notHandled:
            errorHandleWithAppleSignIn()
//            break
        case ASAuthorizationError.unknown:
            errorHandleWithAppleSignIn()
//            break
        default:
            break
        }
        
        print("didCompleteWithError: \(error.localizedDescription)")
    }
    
    func errorHandleWithAppleSignIn() {
        ProgressHUD.shared.view = self.view
        ProgressHUD.showFailure(text: "發生錯誤請稍後再試")

    }
    
}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
