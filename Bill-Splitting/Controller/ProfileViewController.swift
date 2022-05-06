//
//  ProfileViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/12.
//

import UIKit
import Firebase
import FirebaseAuth
import Lottie

class ProfileViewController: UIViewController {
    
    private var animationView = AnimationView()
    let currentUserId = AccountManager.shared.currentUser.currentUserId
    var currentUser: UserData?
    var profileView = UIView()
    let userName = UILabel()
    let userEmail = UILabel()
    let editButton = UIButton()
    var collectionView: UICollectionView!
    var blackList = [String]()
    let screenWidth = UIScreen.main.bounds.width - 20
    
    var profileList: [ProfileList] = [ProfileList.qrCode, ProfileList.payment, ProfileList.friendList, ProfileList.friendInvitation, ProfileList.logOut, ProfileList.deleteAccount]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        getUserData()
        setProfileView()
        setCollectionView()
        
        navigationItem.title = "個人頁面"
    }
    
    func getUserData() {
        UserManager.shared.fetchSignInUserData(userId: currentUserId) { [weak self] result in
            switch result {
            case .success(let user):
                self?.currentUser = user
                self?.userName.text = user?.userName
                self?.userEmail.text = user?.userEmail
                self?.blackList = user?.blackList ?? []
                self?.fetchFriends()
            case.failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchFriends() {
        UserManager.shared.fetchFriendData(userId: currentUserId) { [weak self] result in
            switch result {
            case .success(let friend):
                self?.currentUser?.friends = friend
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
    }
    
    @objc func pressEdit() {
        let alertController = UIAlertController(title: "修改名稱", message: "請輸入使用者名稱", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "新名稱"
        }
        let renameAlert = UIAlertAction(title: "修改", style: .default) { [weak self] _ in
            self?.updateUserName(newUserName: alertController.textFields?[0].text ?? "")
            //            print(alertController.textFields?[0].text)
        }
        let cancelAlert = UIAlertAction(title: "取消", style: .default, handler: nil)
        alertController.addAction(renameAlert)
        alertController.addAction(cancelAlert)
        present(alertController, animated: true, completion: nil)
    }
    
    func updateUserName(newUserName: String) {
        UserManager.shared.updateUserName(userId: currentUserId, userName: newUserName) { [weak self] result in
            switch result {
            case .success:
                print("userName update successfully")
                self?.getUserData()
            case .failure:
                print("userName update failed")
            }
        }
    }
    
    func logOut() {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                backToSignInPage()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func backToSignInPage() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let signInViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: SignInViewController.self))
        view.window?.rootViewController = signInViewController
        view.window?.makeKeyAndVisible()
    }
    
    func deleteAllUserData() {
        if currentUser?.friends == nil {
            deleteUserData()
        } else if currentUser?.friends?.isEmpty == true {
            deleteUserData()
        } else {
            removeFriendData()
        }
    }
    
    func removeFriendData() {
        var isFriendsRemove: Bool = false
        var isUserRemove: Bool = false
        
        let group = DispatchGroup()
        let firstQueue = DispatchQueue(label: "firstQueue", qos: .default, attributes: .concurrent)
        group.enter()
        // MARK: - Delete user's friendList
        firstQueue.async(group: group) {
            UserManager.shared.deleteFriendCollection(documentId: self.currentUserId, collection: "friend") { [weak self] result in
                switch result {
                case .success:
                    print("Delete friends successfully")
                    isFriendsRemove = true
                    
                case .failure(let error):
                    print("\(error.localizedDescription)")
                    ProgressHUD.shared.view = self?.view ?? UIView()
                    ProgressHUD.showFailure(text: "資料刪除失敗，請稍後再試")
                }
                group.leave()
            }
        }
        // MARK: - Delete userData from friend's friendList
        let secondQueue = DispatchQueue(label: "secondQueue", qos: .default, attributes: .concurrent)
        group.enter()
        if let friends = currentUser?.friends {
            for friend in friends {
                group.enter()
                secondQueue.async(group: group) {
                    UserManager.shared.deleteDropUserData(friendId: friend.userId, collection: "friend", userId: self.currentUserId) { [weak self] result in
                        switch result {
                        case .success():
                            print("delete data successfully")
                            isUserRemove = true
                            group.leave()
                        case .failure(let error):
                            print("\(error.localizedDescription)")
                            ProgressHUD.shared.view = self?.view ?? UIView()
                            ProgressHUD.showFailure(text: "資料刪除失敗，請稍後再試")
                            isUserRemove = false
                            group.leave()
                        }
                    }
                }
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            if isUserRemove == true && isFriendsRemove == true {
                self.deleteUserData()
            }
        }
    }

    func deleteUserData() {
        UserManager.shared.deleteUserData(userId: currentUserId, userName: currentUser?.userName ?? "") { [weak self] result in
            switch result {
            case .success:
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showSuccess(text: "資料已刪除")
                self?.deletAccount()
            case .failure(let error):
                print("Error updating document: \(error)")
                //  MARK: - Add alert to tell user: Remove userdata failed
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showFailure(text: "刪除資料失敗，請稍後再試")
            }
        }
    }
    
    func deletAccount() {
        let currentUserName = currentUser?.userName ?? ""
        AccountManager.shared.deleteAccount() { [weak self] result in
            switch result {
            case .success:
                print("Account successfully deleted ")
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showSuccess(text: "帳號已刪除")
                self?.updateUserName(newUserName: currentUserName + "帳號已刪除")
                self?.backToSignInPage()
            case .failure:
                self?.alertSignInAgain()
            }
        }
    }
    
    func alertDeleteAccount() {
        let message = "提醒：若刪除帳號，將刪除您的 email 及收款資訊，但不會刪除您在群組中的帳務資訊。刪除帳號後，將無法回復帳號。"
        let alertController = UIAlertController(title: "刪除帳號",
                                                message: message,
                                                preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "刪除", style: .destructive) { [weak self]_ in
            self?.deleteAllUserData()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func alertSignInAgain() {
        let alertController = UIAlertController(title: "重新登入", message: "若需刪除帳號，請重新登入", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "確認", style: .default, handler: nil)
        
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
}

extension ProfileViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        } else {
            return 2
        }
        //        return profileList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: ProfileCollectionViewCell.self),
            for: indexPath
        )
        
        guard let profileCell = cell as? ProfileCollectionViewCell else { return cell }
        
        if indexPath.section == 0 {
            if indexPath.item == 0 {
                profileCell.textLabel.text = ProfileList.qrCode.content
                profileCell.icon.image = ProfileList.qrCode.icon
            } else if indexPath.item == 1 {
                profileCell.textLabel.text = ProfileList.payment.content
                profileCell.icon.image = ProfileList.payment.icon
            } else if indexPath.item == 2 {
                profileCell.textLabel.text = ProfileList.friendList.content
                profileCell.icon.image = ProfileList.friendList.icon
            } else if indexPath.item == 3 {
                profileCell.textLabel.text = ProfileList.friendInvitation.content
                profileCell.icon.image = ProfileList.friendInvitation.icon
            } else if indexPath.item == 4 {
                profileCell.textLabel.text = ProfileList.blackList.content
                profileCell.icon.image = ProfileList.blackList.icon
            }
        } else {
            if indexPath.item == 0 {
                profileCell.textLabel.text = ProfileList.logOut.content
                profileCell.icon.image = ProfileList.logOut.icon
            } else {
                profileCell.textLabel.text = ProfileList.deleteAccount.content
                profileCell.icon.image = ProfileList.deleteAccount.icon
            }
        }
        return profileCell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeaderView.identifier,
                                                                           for: indexPath) as? ProfileHeaderView else { return UICollectionReusableView()}
        if indexPath.section == 0 {
            header.label.text = "個人資訊"
        } else {
            header.label.text = "帳號"
        }
        header.configure()
        return header
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth: CGFloat = screenWidth / 4 - 5
        let itemHeight: CGFloat = itemWidth
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 24.0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//            var numberOfItemsPerRow: CGFloat
//            let interItemSpacing: CGFloat
//            let screenWidth = UIScreen.main.bounds.width - 20
//
//            interItemSpacing = (screenWidth - (5 * 80)) / 5
//
            return 24
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            
            return CGSize(width: UIScreen.main.bounds.width, height: 48.0)
        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            if indexPath.item == 0 {
                setAnimation()
                let storyBoard = UIStoryboard(name: "Profile", bundle: nil)
                let qrCodeViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: QRCodeViewController.self))
                if #available(iOS 15.0, *) {
                    if let sheet = qrCodeViewController.sheetPresentationController {
                        sheet.detents = [.medium()]
                        sheet.preferredCornerRadius = 20
                    }
                }
                self.present(qrCodeViewController, animated: true, completion: nil)
                removeAnimation()
            } else if indexPath.item == 1 {
                let storyBoard = UIStoryboard(name: "Profile", bundle: nil)
                let paymentViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: PaymentViewController.self))
                self.show(paymentViewController, sender: nil)
            } else if indexPath.item == 2 {
                let storyBoard = UIStoryboard(name: "Profile", bundle: nil)
                let friendListViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: FriendListViewController.self))
                self.show(friendListViewController, sender: nil)
            } else if indexPath.item == 3 {
                let storyBoard = UIStoryboard(name: "Profile", bundle: nil)
                guard let friendInvitationVC = storyBoard.instantiateViewController(withIdentifier: String(describing: FriendInvitationViewController.self)) as? FriendInvitationViewController
                else { return }
                friendInvitationVC.currentUserName = currentUser?.userName
                self.show(friendInvitationVC, sender: nil)
            } else if indexPath.item == 4 {
                let storyBoard = UIStoryboard(name: "Profile", bundle: nil)
                guard let blackListViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: BlackListViewController.self)) as? BlackListViewController
                else { return }
                blackListViewController.blackList = blackList
                self.show(blackListViewController, sender: nil)
            }
        } else {
            if indexPath.item == 0 {
                logOut()
            } else {
                alertDeleteAccount()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.backgroundColor = nil
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.backgroundColor = UIColor(red: 227/255, green: 246/255, blue: 245/255, alpha: 0.5)
        }
    }
}

extension ProfileViewController {
    
    func setCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: (self.view.frame.size.width - 30) / 2, height: 60)
        layout.minimumLineSpacing = CGFloat(integerLiteral: 10)
        layout.minimumInteritemSpacing = CGFloat(integerLiteral: 10)
        layout.scrollDirection = UICollectionView.ScrollDirection.vertical
        layout.headerReferenceSize = CGSize(width: 0, height: 100)
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: profileView.bottomAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
        collectionView.backgroundColor = .clear
        
        collectionView.register(UINib(nibName: String(describing: ProfileCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: ProfileCollectionViewCell.self))
        collectionView.register(ProfileHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: ProfileHeaderView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func setProfileView() {
        self.view.addSubview(profileView)
        profileView.translatesAutoresizingMaskIntoConstraints = false
        setProfileViewConstraint()
        
        profileView.addSubview(userName)
        userName.translatesAutoresizingMaskIntoConstraints = false
        userName.topAnchor.constraint(equalTo: profileView.topAnchor, constant: 20).isActive = true
        userName.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 20).isActive = true
        userName.widthAnchor.constraint(equalTo: profileView.widthAnchor, constant: -40).isActive = true
        userName.heightAnchor.constraint(equalToConstant: 30).isActive = true
        userName.textColor = .greenWhite
        userName.font = userName.font.withSize(20)
        
        profileView.addSubview(userEmail)
        userEmail.translatesAutoresizingMaskIntoConstraints = false
        userEmail.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 10).isActive = true
        userEmail.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 20).isActive = true
        userEmail.widthAnchor.constraint(equalTo: profileView.widthAnchor, constant: -40).isActive = true
        userEmail.heightAnchor.constraint(equalToConstant: 30).isActive = true
        userEmail.textColor = .greenWhite
        
        profileView.addSubview(editButton)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.topAnchor.constraint(equalTo: profileView.topAnchor, constant: 20).isActive = true
        editButton.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -20).isActive = true
        editButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        editButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        editButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        editButton.tintColor = .greenWhite
        editButton.addTarget(self, action: #selector(pressEdit), for: .touchUpInside)
    }
    
    func setProfileViewConstraint() {
        profileView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        profileView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        profileView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        profileView.heightAnchor.constraint(equalToConstant: 100).isActive = true
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

enum ProfileList {
    case qrCode
    case payment
    case friendList
    case friendInvitation
    case blackList
    case logOut
    case deleteAccount
    
    var content: String {
        switch self {
        case .qrCode:
            return "QRCode"
        case .payment:
            return "付款方式"
        case .friendList:
            return "好友列表"
        case .friendInvitation:
            return "交友邀請"
        case .blackList:
            return "黑名單"
        case .logOut:
            return "登出"
        case .deleteAccount:
            return "刪除帳號"
        }
    }
    
    var icon: UIImage {
        switch self {
        case .qrCode:
            return UIImage(systemName: "qrcode") ?? UIImage()
        case .payment:
            return UIImage(systemName: "creditcard") ?? UIImage()
        case .friendList:
            return UIImage(systemName: "person.2.fill") ?? UIImage()
        case .friendInvitation:
            return UIImage(systemName: "mail.fill") ?? UIImage()
        case .blackList:
            return UIImage(systemName: "xmark.rectangle.fill") ?? UIImage()
        case .logOut:
            if #available(iOS 15, *) {
                return UIImage(systemName: "rectangle.portrait.and.arrow.right.fill") ?? UIImage()
            } else {
                return UIImage(systemName: "arrow.turn.down.right") ?? UIImage()
            }
        case .deleteAccount:
            return UIImage(systemName: "person.crop.circle.fill.badge.xmark") ?? UIImage()
        }
    }
}
