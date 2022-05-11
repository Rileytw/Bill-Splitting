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
    
    var appName = UIImageView()
    private var animationView = AnimationView()
    var accountTextField = UITextField()
    var passwordTextField = UITextField()
    var logInButton = UIButton()
    var signUpButton = UIButton()
    var thirdPartyId: String?
    var appleId: String?
    
    var privacyButton = UIButton()
    var eulaButton = UIButton()
    let width = UIScreen.main.bounds.width
    
    fileprivate var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        setAppName()
        setAccountTextField()
        setPasswordTextField()
        setLoginButton()
        setAppleSignInButton()
        setSignUpButton()
        checkUserSignIn()
        setPrivacyButton()
        setEulaButton()
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
            enterFirstPage()
        }
    }
    
    func setAccountTextField() {
        view.addSubview(accountTextField)
        accountTextField.translatesAutoresizingMaskIntoConstraints = false
        setAccountTextFieldConstraint()
        accountTextField.attributedPlaceholder = NSAttributedString(string: "輸入帳號",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
    }
    
    func setPasswordTextField() {
        view.addSubview(passwordTextField)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        setPasswordTextFieldConstraint()
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "輸入密碼",
                                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
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
                self?.enterFirstPage()
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
    
    func enterFirstPage() {
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
    
    func setAppName() {
        view.addSubview(appName)
        appName.translatesAutoresizingMaskIntoConstraints = false
        appName.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
        appName.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        appName.widthAnchor.constraint(equalToConstant: 200).isActive = true
        appName.heightAnchor.constraint(equalToConstant: 100).isActive = true
        appName.contentMode = .scaleAspectFill
        
        appName.image = UIImage(named: "Launch")
    }
    
    func setAccountTextFieldConstraint() {
        accountTextField.topAnchor.constraint(equalTo: view.centerYAnchor, constant: -150).isActive = true
        accountTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        accountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        accountTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setPasswordTextFieldConstraint() {
        passwordTextField.topAnchor.constraint(equalTo: accountTextField.bottomAnchor, constant: 20).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        passwordTextField.isSecureTextEntry = true
    }
    
    func setLoginButtonConstraint() {
        logInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 60).isActive = true
        logInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        logInButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
        logInButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setAuthorizationButtonConstraint() {
        authorizationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        authorizationButton.topAnchor.constraint(equalTo: logInButton.bottomAnchor, constant: 40).isActive = true
        authorizationButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
        authorizationButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setSignUpconstraint() {
        signUpButton.topAnchor.constraint(equalTo: authorizationButton.bottomAnchor, constant: 20).isActive = true
        signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        signUpButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
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
        user.userName = "\(credential.fullName?.givenName ?? "")"
        user.userEmail = "\(credential.email ?? "")"
        
        firebaseSignInWithApple(credential: appCredential)
    }
    
    func firebaseSignInWithApple(credential: AuthCredential) {
        setAnimation()
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            if error == nil {
                self?.getFirebaseUserInfo()
            } else {
                self?.errorHandleWithAppleSignIn()
            }
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
                self?.enterFirstPage()
            case .failure(let error):
                print("Error decoding userData: \(error)")
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showFailure(text: "發生錯誤，請重新登入")
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
    
    func setPrivacyButton() {
        let privacyLabel = UILabel()
        view.addSubview(privacyLabel)
        privacyLabel.translatesAutoresizingMaskIntoConstraints = false
        privacyLabel.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 20).isActive = true
        privacyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: (width - 316)/2 ).isActive = true
        privacyLabel.widthAnchor.constraint(equalToConstant: 130).isActive = true
        privacyLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        privacyLabel.text = "點擊登入表示您同意"
        privacyLabel.textColor = .systemGray
        privacyLabel.font = privacyLabel.font.withSize(14)
        
        view.addSubview(privacyButton)
        privacyButton.translatesAutoresizingMaskIntoConstraints = false
        privacyButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 20).isActive = true
        privacyButton.leadingAnchor.constraint(equalTo: privacyLabel.trailingAnchor, constant: 0).isActive = true
        privacyButton.widthAnchor.constraint(equalToConstant: 90).isActive = true
        privacyButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        privacyButton.setTitle("隱私權政策 &", for: .normal)
        privacyButton.setTitleColor(.systemGray, for: .normal)
        privacyButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        privacyButton.addTarget(self, action: #selector(pressPrivacyButton), for: .touchUpInside)
        privacyButton.titleLabel?.font = privacyButton.titleLabel?.font.withSize(14)
    }
    
    @objc func pressPrivacyButton() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let webViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: WebViewController.self)) as? WebViewController else { return }
        webViewController.url = PolicyUrl.privacy.url
        self.present(webViewController, animated: true, completion: nil)
    }
    
    func setEulaButton() {
        view.addSubview(eulaButton)
        eulaButton.translatesAutoresizingMaskIntoConstraints = false
        eulaButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 20).isActive = true
        eulaButton.leadingAnchor.constraint(equalTo: privacyButton.trailingAnchor, constant: 0).isActive = true
        eulaButton.widthAnchor.constraint(equalToConstant: 96).isActive = true
        eulaButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        eulaButton.setTitle("用戶許可協議", for: .normal)
        eulaButton.setTitleColor(.systemGray, for: .normal)
        eulaButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        eulaButton.titleLabel?.font = eulaButton.titleLabel?.font.withSize(14)
        eulaButton.addTarget(self, action: #selector(pressEulaButton), for: .touchUpInside)
    }
    
    @objc func pressEulaButton() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let webViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: WebViewController.self)) as? WebViewController else { return }
        webViewController.url = PolicyUrl.eula.url
        self.present(webViewController, animated: true, completion: nil)
    }
    
}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
