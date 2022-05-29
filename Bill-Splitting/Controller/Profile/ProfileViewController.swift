//
//  ProfileViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/12.
//

import UIKit

class ProfileViewController: BaseViewController {
    
    // MARK: - Property
    var profileView = UIView()
    var profileImage = UIImageView()
    let userName = UILabel()
    let userEmail = UILabel()
    let editButton = UIButton()
    var collectionView: UICollectionView!
    var editingView = EditingView()
    var editingViewBottom: NSLayoutConstraint?
    var personalInfoList: [ProfileList] = [ProfileList.qrCode,
                                           ProfileList.payment,
                                           ProfileList.friendList,
                                           ProfileList.friendInvitation,
                                           ProfileList.blockList]
    var accountList: [ProfileList] = [ProfileList.logOut,
                                      ProfileList.deleteAccount]
    let currentUserId = AccountManager.shared.currentUser.currentUserId
    var currentUser: UserData?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        getUserData()
        setProfileView()
        setCollectionView()
        setAddGroupButton()
        
        navigationItem.title = NavigationItemName.profile.name
    }
    
    // MARK: - Method
    func getUserData() {
        UserManager.shared.fetchSignInUserData(userId: currentUserId) { [weak self] result in
            switch result {
            case .success(let user):
                self?.currentUser = user
                self?.userName.text = user?.userName
                self?.userEmail.text = user?.userEmail
                self?.fetchFriends()
            case.failure:
                self?.showFailure(text: ErrorType.generalError.errorMessage)
            }
        }
    }
    
    func fetchFriends() {
        UserManager.shared.fetchFriendData(userId: currentUserId) { [weak self] result in
            switch result {
            case .success(let friend):
                self?.currentUser?.friends = friend
            case .failure:
                self?.showFailure(text: ErrorType.generalError.errorMessage)
            }
        }
    }
    
    func setAddGroupButton() {
        let editButton = UIBarButtonItem.init(title: "編輯",
                                              style: UIBarButtonItem.Style.plain,
                                              target: self, action: #selector(revealBlockView))
        self.navigationItem.setRightBarButton(editButton, animated: true)
    }
    
    func updateUserName(newUserName: String) {
        UserManager.shared.updateUserName(userId: currentUserId, userName: newUserName) { [weak self] result in
            switch result {
            case .success:
                self?.getUserData()
                self?.pressDismissButton()
            case .failure:
                self?.showFailure(text: ErrorType.dataModifyError.errorMessage)
            }
        }
    }
    
    func updateUserNameInFriendList(friendId: String, newName: String) {
        FriendManager.shared.updateFriendNewName(
            friendId: friendId, currentUserId: currentUserId, currentUserName: newName)
    }
    
    func logOut() {
        AccountManager.shared.logOutAccount { [weak self] result in
            switch result {
            case .success:
                self?.backToSignInPage()
            case .failure:
                self?.showFailure(text: ErrorType.generalError.errorMessage)
            }
        }
    }
    
    func backToSignInPage() {
        let storyBoard = UIStoryboard(name: StoryboardCategory.main, bundle: nil)
        let signInViewController = storyBoard.instantiateViewController(
            withIdentifier: SignInViewController.identifier)
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
        group.enter()
        // MARK: - Delete user's friendList
        DispatchQueue.global().async {
            UserManager.shared.deleteFriendCollection(
                documentId: self.currentUserId,
                collection: FirebaseCollection.friend.rawValue) { [weak self] result in
                    switch result {
                    case .success:
                        isFriendsRemove = true
                    case .failure:
                        self?.showFailure(text: ErrorType.dataDeleteError.errorMessage)
                    }
                    group.leave()
                }
        }
        // MARK: - Delete userData from friend's friendList
        group.enter()
        if let friends = currentUser?.friends {
            for friend in friends {
                group.enter()
                DispatchQueue.global().async {
                    UserManager.shared.deleteDropUserData(
                        friendId: friend.userId,
                        collection: FirebaseCollection.friend.rawValue,
                        userId: self.currentUserId) { [weak self] result in
                            switch result {
                            case .success:
                                isUserRemove = true
                                group.leave()
                            case .failure:
                                self?.showFailure(text: ErrorType.dataDeleteError.errorMessage)
                                isUserRemove = false
                                group.leave()
                            }
                        }
                }
            }
        }
        
        group.notify(queue: DispatchQueue.main) { [weak self] in
            if isUserRemove == true && isFriendsRemove == true {
                self?.deleteUserData()
            }
        }
    }
    
    func deleteUserData() {
        UserManager.shared.deleteUserData(
            userId: currentUserId, userName: currentUser?.userName ?? "") { [weak self] result in
                switch result {
                case .success:
                    self?.showSuccess(text: SuccessType.deleteSuccess.successMessage)
                    self?.deletAccount()
                case .failure:
                    // MARK: - Add alert to tell user: Remove userdata failed
                    self?.showFailure(text: ErrorType.dataDeleteError.errorMessage)
                }
            }
    }
    
    func deletAccount() {
        let currentUserName = currentUser?.userName ?? ""
        AccountManager.shared.deleteAccount { [weak self] result in
            switch result {
            case .success:
                self?.showSuccess(text: "帳號已刪除")
                self?.updateUserName(newUserName: currentUserName + "（帳號已刪除）")
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
        confirmAlert(title: "重新登入", message: "若需刪除帳號，請重新登入")
    }
    
}

extension ProfileViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return personalInfoList.count
        } else {
            return accountList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: ProfileCollectionViewCell.self),
            for: indexPath
        )
        guard let profileCell = cell as? ProfileCollectionViewCell else { return cell }
        
        switch indexPath.section {
        case 0:
            switch indexPath.item {
            case 0:
                profileCell.createProfileCell(image: ProfileList.qrCode.icon, text: ProfileList.qrCode.content)
            case 1:
                profileCell.createProfileCell(image: ProfileList.payment.icon, text: ProfileList.payment.content)
            case 2:
                profileCell.createProfileCell(image: ProfileList.friendList.icon, text: ProfileList.friendList.content)
            case 3:
                profileCell.createProfileCell(image: ProfileList.friendInvitation.icon,
                                              text: ProfileList.friendInvitation.content)
            case 4:
                profileCell.createProfileCell(image: ProfileList.blockList.icon, text: ProfileList.blockList.content)
            default:
                return profileCell
            }
        case 1:
            if indexPath.item == 0 {
                profileCell.createProfileCell(image: ProfileList.logOut.icon, text: ProfileList.logOut.content)
            } else {
                profileCell.createProfileCell(image: ProfileList.deleteAccount.icon,
                                              text: ProfileList.deleteAccount.content)
            }
        default:
            return profileCell
        }
        return profileCell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ProfileHeaderView.identifier,
            for: indexPath) as? ProfileHeaderView else { return UICollectionReusableView()}
        if indexPath.section == 0 {
            header.label.text = ProfileSection.personalInfo.name
        } else {
            header.label.text = ProfileSection.account.name
        }
        header.configure()
        return header
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.width - 20
        let itemWidth: CGFloat = screenWidth / 4 - 5
        let itemHeight: CGFloat = itemWidth
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 24.0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 24
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: UIScreen.width, height: 48.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: StoryboardCategory.profile, bundle: nil)
        switch indexPath.section {
        case 0:
            switch indexPath.item {
            case 0:
                setAnimation()
                let qrCodeViewController = storyBoard.instantiateViewController(
                    withIdentifier: QRCodeViewController.identifier)
                if #available(iOS 15.0, *) {
                    if let sheet = qrCodeViewController.sheetPresentationController {
                        sheet.detents = [.medium()]
                        sheet.preferredCornerRadius = 20
                    }
                }
                self.present(qrCodeViewController, animated: true, completion: nil)
                removeAnimation()
            case 1:
                let paymentViewController = storyBoard.instantiateViewController(
                    withIdentifier: PaymentViewController.identifier)
                self.show(paymentViewController, sender: nil)
            case 2:
                let friendListViewController = storyBoard.instantiateViewController(
                    withIdentifier: FriendListViewController.identifier)
                self.show(friendListViewController, sender: nil)
            case 3:
                guard let friendInvitationVC = storyBoard.instantiateViewController(
                    withIdentifier: FriendInvitationViewController.identifier
                ) as? FriendInvitationViewController else { return }
                friendInvitationVC.currentUserName = currentUser?.userName
                self.show(friendInvitationVC, sender: nil)
            case 4:
                guard let blockListViewController = storyBoard.instantiateViewController(
                    withIdentifier: BlockListViewController.identifier) as? BlockListViewController
                else { return }
                self.show(blockListViewController, sender: nil)
            default:
                return
            }
        case 1:
            if indexPath.item == 0 {
                logOut()
            } else {
                alertDeleteAccount()
            }
        default:
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.backgroundColor = nil
            UIView.animate(withDuration: 0.2) {
                cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.backgroundColor = UIColor(red: 227/255, green: 246/255, blue: 245/255, alpha: 0.5)
            UIView.animate(withDuration: 0.2) {
                cell.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
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
        collectionView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        collectionView.backgroundColor = .clear
        
        collectionView.register(
            UINib(nibName: String(describing: ProfileCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: ProfileCollectionViewCell.self))
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
        setProfileImage()
        
        profileView.addSubview(userName)
        userName.translatesAutoresizingMaskIntoConstraints = false
        userName.topAnchor.constraint(equalTo: profileView.topAnchor, constant: 30).isActive = true
        userName.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 20).isActive = true
        userName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        userName.textColor = .greenWhite
        userName.font = userName.font.withSize(20)
        
        profileView.addSubview(userEmail)
        userEmail.translatesAutoresizingMaskIntoConstraints = false
        userEmail.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 10).isActive = true
        userEmail.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 20).isActive = true
        userEmail.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        userEmail.textColor = .greenWhite
        userEmail.font = userEmail.font.withSize(18)
        userEmail.adjustsFontSizeToFitWidth = true
    }
    
    func setProfileImage() {
        profileView.addSubview(profileImage)
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.topAnchor.constraint(equalTo: profileView.topAnchor, constant: 30).isActive = true
        profileImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 60).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        profileImage.image = UIImage(named: "profile")
    }
    
    func setProfileViewConstraint() {
        profileView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        profileView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        profileView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        profileView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
}

extension ProfileViewController {
    private func setEditingView() {
        editingView.removeFromSuperview()
        view.addSubview(editingView)
        editingView.translatesAutoresizingMaskIntoConstraints = false
        editingView.backgroundColor = .viewDarkBackgroundColor
        editingView.buttonTitle = "完成"
        editingView.textField.text = currentUser?.userName ?? ""
        editingView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        editingView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        editingView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        editingViewBottom = editingView.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        editingViewBottom?.isActive = true
        view.layoutIfNeeded()
    }
    
    @objc func revealBlockView() {
        view.stickSubView(mask)
        mask.backgroundColor = .maskBackgroundColor
        
        setEditingView()
        
        editingViewBottom?.constant = -300
        UIView.animate(withDuration: 0.25, delay: 0,
                       options: UIView.AnimationOptions.curveEaseIn, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: nil)
        
        editingView.completeButton.addTarget(self, action: #selector(checkUserNameEmpty), for: .touchUpInside)
        editingView.dismissButton.addTarget(self, action: #selector(pressDismissButton), for: .touchUpInside)
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func checkUserNameEmpty() {
        if editingView.textField.text == "" {
            confirmAlert(title: "請填寫使用者名稱", message: "使用這名稱不可空白")
        } else {
            let newName = editingView.textField.text ?? ""
            updateUserName(newUserName: newName)
            if let friends = currentUser?.friends {
                for friend in friends {
                    updateUserNameInFriendList(friendId: friend.userId, newName: newName)
                }
            }
        }
    }
    
    @objc func pressDismissButton() {
        editingViewBottom?.constant = 0
        UIView.animate(withDuration: 0.25, delay: 0,
                       options: UIView.AnimationOptions.curveEaseIn, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: nil)
        mask.removeFromSuperview()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    enum ProfileList {
        case qrCode, payment, friendList, friendInvitation, blockList, logOut, deleteAccount
        
        var content: String {
            switch self {
            case .qrCode: return "QRCode"
            case .payment: return "付款方式"
            case .friendList: return "好友列表"
            case .friendInvitation: return "交友邀請"
            case .blockList: return "黑名單"
            case .logOut: return "登出"
            case .deleteAccount: return "刪除帳號"
            }
        }
        
        var icon: UIImage {
            switch self {
            case .qrCode: return UIImage(systemName: "qrcode") ?? UIImage()
            case .payment: return UIImage(systemName: "creditcard") ?? UIImage()
            case .friendList: return UIImage(systemName: "person.2.fill") ?? UIImage()
            case .friendInvitation: return UIImage(systemName: "mail.fill") ?? UIImage()
            case .blockList: return UIImage(systemName: "xmark.rectangle.fill") ?? UIImage()
            case .logOut:
                if #available(iOS 15, *) {
                    return UIImage(systemName: "rectangle.portrait.and.arrow.right.fill") ?? UIImage()
                } else {
                    return UIImage(systemName: "arrow.turn.down.right") ?? UIImage()
                }
            case .deleteAccount: return UIImage(systemName: "person.crop.circle.fill.badge.xmark") ?? UIImage()
            }
        }
    }
    
    enum ProfileSection {
        case personalInfo
        case account
        
        var name: String {
            switch self {
            case .personalInfo:
                return "個人資訊"
            case .account:
                return "帳號"
            }
        }
    }
}
