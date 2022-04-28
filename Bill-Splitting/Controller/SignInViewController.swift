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

class SignInViewController: UIViewController {
    
    let authorizationButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
    var user: UserData = UserData(userId: "", userName: "", userEmail: "", group: nil, payment: nil)
    
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
        setAccount()
        setAccountTextField()
        setPassword()
        setPasswordTextField()
        setLoginButton()
        setAppleSignInButton()
        setSignUpButton()
//        checkAppleIDCredentialState(userID: appleId ?? "")
        checkUserSignIn()
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
        logInButton.addTarget(self, action: #selector(pressLogin), for: .touchUpInside)
    }
    
    @objc func pressLogin() {
        AccountManager.shared.signInWithFirebase(email: accountTextField.text ?? "",
                                                password: passwordTextField.text ?? "") { [weak self] firebaseId in
            self?.fetchUserData(userId: firebaseId)
        }
    }
    
    func fetchUserData(userId: String) {
        
        UserManager.shared.fetchSignInUserData(userId: userId) { [weak self] result in
            switch result {
            case .success(let user):
                print(user)
                if user == nil {
                    self?.user.userId = userId
                    self?.addNewUserData()
                }
                self?.user.userName = user?.userName ?? ""
                self?.user.userEmail = user?.userEmail ?? ""
                self?.user.userId = user?.userId ?? ""
                print("Login successed!")
                self?.enterFistPage()
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
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
    
//    func checkAppleIDCredentialState(userID: String) {
//        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID) { [weak self] credentialState, error in
//            switch credentialState {
//            case .authorized:
//                self?.fetchUserData(userId: userID)
//            default:
//                break
//            }
//        }
//    }
    
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
//        let email = user.email
        self.user.userId = uid
        fetchUserData(userId: uid)
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
