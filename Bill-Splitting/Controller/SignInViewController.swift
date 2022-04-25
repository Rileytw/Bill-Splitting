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
    var user: UserData = UserData(userId: "", userName: "", userEmail: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSignInButton()
    }
    
    func setSignInButton() {
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
    
    func setAuthorizationButtonConstraint() {
        authorizationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        authorizationButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        authorizationButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        authorizationButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
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
        
        user.userName = "\(credential.fullName)"
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
