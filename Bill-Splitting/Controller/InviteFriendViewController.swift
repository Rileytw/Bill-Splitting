//
//  InviteFriendViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/12.
//

import UIKit

class InviteFriendViewController: UIViewController {
    
    // MARK: - Property
    let nameLabel = UILabel()
    let friendTextField = UITextField()
    let searchButton = UIButton()
    let friendNameLabel = UILabel()
    let sendButton = UIButton()
    var scanQRCode = UIButton()
    let currentUserId = UserManager.shared.currentUser?.userId ?? ""
    var friendData: UserData?
    var friendList: [Friend]?
    var searchId: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        setTextField()
        setSearchButton()
        setSearchResult()
        setScanQRCodeButton()
        setDismissButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        friendNameLabel.isHidden = true
        sendButton.isHidden = true
    }
    
    // MARK: - Method
    @objc func pressScanQRCode() {
        let storyBoard = UIStoryboard(name: StoryboardCategory.addGroups, bundle: nil)
        guard let scanQRCodeViewController = storyBoard.instantiateViewController(
            withIdentifier: ScanQRCodeViewController.identifier) as? ScanQRCodeViewController else { return }
        
        self.present(scanQRCodeViewController, animated: true, completion: nil)
        
        scanQRCodeViewController.qrCodeContent = { [weak self] qrCode in
            self?.searchFriend(userEmail: qrCode)
        }
    }
    
    @objc func pressSearchButton() {
        if friendTextField.text?.isEmpty == false {
            searchFriend(userEmail: friendTextField.text ?? "")
        } else {
            let alertController = UIAlertController(title: "請輸入好友 Email", message: "尚未輸入 Email", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "確認", style: .cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func searchFriend(userEmail: String) {
        FriendManager.shared.fetchFriendUserData(userEmail: userEmail) { [weak self] result in
            switch result {
            case .success(let user):
                self?.friendData = user
                self?.searchId = user.userId
                self?.friendNameLabel.isHidden = true
                self?.detectFriendStatus()
                
            case .failure:
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showFailure(text: ErrorType.generalError.errorMessage)
            }
        }
        
        if self.friendData == nil {
            self.friendNameLabel.text = "無符合對象"
            self.friendNameLabel.isHidden = false
            self.sendButton.isHidden = true
        }
    }
    
    func detectFriendStatus() {
        let group = DispatchGroup()
        var searchResult: String?
        var isFriend: Bool = false
        var isInvitationSend: Bool = false
        var isInvitationReceive: Bool = false
        var isBlockUser: Bool = false
        var isFetchDataSuccess: Bool = false
        
        group.enter()
        DispatchQueue.global().async {
            // MARK: - Detect FriendList
            UserManager.shared.fetchFriendData(userId: self.currentUserId) { [weak self] result in
                switch result {
                case .success(let friend):
                    let friendId = friend.map { $0.userId }
                    if friendId.contains(self?.friendData?.userId ?? "") {
                        isFriend = true
                    }
                    isFetchDataSuccess = true
                case .failure:
                    isFetchDataSuccess = false
                }
                group.leave()
            }
        }
        // MARK: - Detect invitation
        group.enter()
        DispatchQueue.global().async {
            
            FriendManager.shared.fetchReceiverInvitation(
                userId: self.currentUserId, friendId: self.friendData?.userId ?? "") { result in
                    switch result {
                    case .success(let invitaion):
                        if invitaion != nil {
                            isInvitationReceive = true
                        }
                        isFetchDataSuccess = true
                    case .failure:
                        isFetchDataSuccess = false
                    }
                    group.leave()
                }
            
        }
        // MARK: - Detect invitation
        group.enter()
        DispatchQueue.global().async {
            
            FriendManager.shared.fetchSenderInvitation(
                userId: self.currentUserId, friendId: self.friendData?.userId ?? "") { result in
                    switch result {
                    case .success(let invitaion):
                        if invitaion != nil {
                            isInvitationSend = true
                        }
                        isFetchDataSuccess = true
                    case .failure:
                        isFetchDataSuccess = false
                    }
                    group.leave()
                }
        }
        
        // MARK: - Detect blockUser
        group.enter()
        DispatchQueue.global().async {
            
            UserManager.shared.fetchUserData(friendId: self.searchId ?? "") { [weak self] result in
                switch result {
                case .success(let searchUser):
                    let blockList = searchUser?.blackList
                    if ((blockList?.contains(self?.currentUserId ?? "")) != nil) {
                        isBlockUser = true
                    }
                    isFetchDataSuccess = true
                case .failure:
                    isFetchDataSuccess = false
                }
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) { [weak self] in
            switch isFetchDataSuccess {
            case true:
                if isFriend == true {
                    searchResult = self?.showSearchResult(
                        status: FriendStatus.isFriend.searchResult, buttonHidden: true)
                } else if isInvitationReceive == true {
                    searchResult = self?.showSearchResult(
                        status: FriendStatus.receivedInvitaion.searchResult, buttonHidden: true)
                } else if isInvitationSend == true {
                    searchResult = self?.showSearchResult(
                        status: FriendStatus.sentInvitaion.searchResult, buttonHidden: true)
                } else if isBlockUser == true {
                    searchResult = self?.showSearchResult(
                        status: FriendStatus.block.searchResult, buttonHidden: true)
                } else if self?.friendData == nil {
                    searchResult = self?.showSearchResult(
                        status: FriendStatus.emptyData.searchResult, buttonHidden: true)
                } else {
                    searchResult = self?.showSearchResult(
                        status: self?.friendData?.userName ?? "", buttonHidden: false)
                }
                
                self?.friendNameLabel.text = searchResult
                self?.friendNameLabel.isHidden = false
            case false:
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showFailure(text: ErrorType.generalError.errorMessage)
            }
        }
    }
    
    private func showSearchResult(status: String, buttonHidden: Bool) -> String {
        sendButton.isHidden = buttonHidden
        let nameText = status
        return nameText
    }
    
    @objc func pressSendButton() {
        FriendManager.shared.updateFriendInvitation(senderId: currentUserId,
                                                    receiverId: self.friendData?.userId ?? "") { [weak self] in
            ProgressHUD.shared.view = self?.view ?? UIView()
            ProgressHUD.showSuccess(text: "已寄出邀請")
            self?.friendData = nil
            self?.sendButton.isHidden = true
            self?.friendNameLabel.isHidden = true
            self?.friendTextField.text = ""
        }
    }
    
    func setScanQRCodeButtonConstraint() {
        scanQRCode.topAnchor.constraint(equalTo: friendTextField.bottomAnchor, constant: 20).isActive = true
        scanQRCode.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        scanQRCode.widthAnchor.constraint(equalToConstant: 160).isActive = true
        scanQRCode.heightAnchor.constraint(equalToConstant: 40).isActive = true
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
}

extension InviteFriendViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.friendData = nil
        friendNameLabel.text = ""
    }
}

extension InviteFriendViewController {
    func setNameLabelConstraint() {
        NSLayoutConstraint(item: nameLabel, attribute: .top,
                           relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                           attribute: .top, multiplier: 1, constant: 60).isActive = true
        NSLayoutConstraint(item: nameLabel, attribute: .leading,
                           relatedBy: .equal, toItem: view,
                           attribute: .leading, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: nameLabel, attribute: .width,
                           relatedBy: .equal, toItem: view,
                           attribute: .width, multiplier: 2/3, constant: -20).isActive = true
        NSLayoutConstraint(item: nameLabel, attribute: .height,
                           relatedBy: .equal, toItem: nil,
                           attribute: .notAnAttribute, multiplier: 0, constant: 40).isActive = true
    }
    
    func setTextFieldConstraint() {
        NSLayoutConstraint(item: friendTextField, attribute: .top,
                           relatedBy: .equal, toItem: nameLabel,
                           attribute: .bottom, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: friendTextField, attribute: .leading,
                           relatedBy: .equal, toItem: view,
                           attribute: .leading, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: friendTextField, attribute: .width,
                           relatedBy: .equal, toItem: view,
                           attribute: .width, multiplier: 2/3, constant: 0).isActive = true
        NSLayoutConstraint(item: friendTextField, attribute: .height,
                           relatedBy: .equal, toItem: nil,
                           attribute: .notAnAttribute, multiplier: 0, constant: 40).isActive = true
    }
    
    func setTextField() {
        
        nameLabel.text = "寄送好友邀請"
        nameLabel.textColor = .greenWhite
        nameLabel.font = nameLabel.font.withSize(24)
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        setNameLabelConstraint()
        
        friendTextField.borderStyle = UITextField.BorderStyle.roundedRect
        friendTextField.layer.borderColor = UIColor.selectedColor.cgColor
        friendTextField.layer.borderWidth = 1
        friendTextField.backgroundColor = .clear
        friendTextField.textColor = .greenWhite
        self.view.addSubview(friendTextField)
        friendTextField.translatesAutoresizingMaskIntoConstraints = false
        setTextFieldConstraint()
        friendTextField.delegate = self
        friendTextField.layer.cornerRadius = 10
        friendTextField.attributedPlaceholder = NSAttributedString(
            string: "輸入 email 搜尋",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
    }
    
    func setSearchButton() {
        searchButton.setTitle("搜尋", for: .normal)
        searchButton.backgroundColor = .systemGray
        view.addSubview(searchButton)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.centerYAnchor.constraint(equalTo: friendTextField.centerYAnchor).isActive = true
        searchButton.leadingAnchor.constraint(equalTo: friendTextField.trailingAnchor, constant: 20).isActive = true
        searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        searchButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        ElementsStyle.styleSpecificButton(searchButton)
        searchButton.addTarget(self, action: #selector(pressSearchButton), for: .touchUpInside)
    }
    
    func setSearchResult() {
        sendButton.setTitle("寄送", for: .normal)
        ElementsStyle.styleSpecificButton(sendButton)
        view.addSubview(sendButton)
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.heightAnchor.constraint(equalTo: searchButton.heightAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalTo: searchButton.widthAnchor).isActive = true
        sendButton.centerXAnchor.constraint(equalTo: searchButton.centerXAnchor).isActive = true
        sendButton.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 100).isActive = true
        
        sendButton.addTarget(self, action: #selector(pressSendButton), for: .touchUpInside)
        
        friendNameLabel.text = friendData?.userName
        friendNameLabel.textColor = .greenWhite
        view.addSubview(friendNameLabel)
        friendNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        friendNameLabel.topAnchor.constraint(equalTo: friendTextField.bottomAnchor, constant: 100).isActive = true
        friendNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        friendNameLabel.widthAnchor.constraint(equalTo: friendTextField.widthAnchor).isActive = true
        friendNameLabel.heightAnchor.constraint(equalTo: friendTextField.heightAnchor).isActive = true
    }
    
    func setScanQRCodeButton() {
        view.addSubview(scanQRCode)
        scanQRCode.translatesAutoresizingMaskIntoConstraints = false
        setScanQRCodeButtonConstraint()
        scanQRCode.setTitle("掃描 QRCode", for: .normal)
        scanQRCode.setTitleColor(.greenWhite, for: .normal)
        ElementsStyle.styleSpecificButton(scanQRCode)
        scanQRCode.addTarget(self, action: #selector(pressScanQRCode), for: .touchUpInside)
    }
    
    enum FriendStatus {
        case notFriend
        case isFriend
        case sentInvitaion
        case receivedInvitaion
        case block
        case emptyData
        
        var searchResult: String {
            switch self {
            case .notFriend:
                return ""
            case .isFriend:
                return "你們已是好友"
            case .sentInvitaion:
                return "已寄送好友邀請"
            case .receivedInvitaion:
                return "對方已寄送好友邀請"
            case .block:
                return "無符合對象"
            case .emptyData:
                return "無符合對象"
            }
        }
    }
}
