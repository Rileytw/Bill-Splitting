//
//  InviteFriendViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/12.
//

import UIKit

class InviteFriendViewController: UIViewController {
    
    let currentUserId = AccountManager.shared.currentUser.currentUserId
    let friendTextField = UITextField()
    let searchButton = UIButton()
    let friendNameLabel = UILabel()
    let sendButton = UIButton()
    var scanQRCode = UIButton()
    var friendData: UserData?
    var friendList: [Friend]?
    
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
    
    func setTextField() {
        let nameLabel = UILabel()
        nameLabel.text = "寄送好友邀請"
        nameLabel.textColor = .greenWhite
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: nameLabel, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 100).isActive = true
        NSLayoutConstraint(item: nameLabel, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: nameLabel, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 2/3, constant: -20).isActive = true
        NSLayoutConstraint(item: nameLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 40).isActive = true
        
        friendTextField.borderStyle = UITextField.BorderStyle.roundedRect
        friendTextField.layer.borderColor = UIColor.selectedColor.cgColor
        friendTextField.layer.borderWidth = 1
        friendTextField.backgroundColor = .clear
        friendTextField.textColor = .greenWhite
        self.view.addSubview(friendTextField)
        friendTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: friendTextField, attribute: .top, relatedBy: .equal, toItem: nameLabel, attribute: .bottom, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: friendTextField, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: friendTextField, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 2/3, constant: 0).isActive = true
        NSLayoutConstraint(item: friendTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 40).isActive = true
        
        friendTextField.delegate = self
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
//        sendButton.backgroundColor = .systemGray
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
        friendNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        friendNameLabel.widthAnchor.constraint(equalTo: friendTextField.widthAnchor).isActive = true
        friendNameLabel.heightAnchor.constraint(equalTo: friendTextField.heightAnchor).isActive = true
    }
    
    func setScanQRCodeButton() {
        view.addSubview(scanQRCode)
        scanQRCode.translatesAutoresizingMaskIntoConstraints = false
        setScanQRCodeButtonConstraint()
        scanQRCode.setTitle("掃描 QRCode", for: .normal)
        scanQRCode.setTitleColor(.greenWhite, for: .normal)
//        scanQRCode.contentHorizontalAlignment = .left
        ElementsStyle.styleSpecificButton(scanQRCode)
        scanQRCode.addTarget(self, action: #selector(pressScanQRCode), for: .touchUpInside)
    }
    
    @objc func pressScanQRCode() {
        let storyBoard = UIStoryboard(name: "AddGroups", bundle: nil)
        guard let scanQRCodeViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: ScanQRCodeViewController.self)) as? ScanQRCodeViewController else { return }
        
        scanQRCodeViewController.qrCodeContent = { [weak self] qrCode in
            self?.searchFriend(userEmail: qrCode)
        }
        self.present(scanQRCodeViewController, animated: true, completion: nil)
    }
    
    @objc func pressSearchButton() {
        searchFriend(userEmail: friendTextField.text ?? "")
    }
    
    func searchFriend(userEmail: String) {
        FriendManager.shared.fetchFriendUserData(userEmail: userEmail) { [weak self] result in
            switch result {
            case .success(let user):
                self?.friendData = user
                //                print("userData: \(self.userData)")
                self?.friendNameLabel.isHidden = true
                self?.friendNameLabel.text = self?.friendData?.userName
                //                self.detectFriendList()
                self?.detectInvitation()
                self?.detectFriendList()
                
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
        
        if self.friendData == nil {
            self.friendNameLabel.text = "無符合對象"
            self.friendNameLabel.isHidden = false
            self.sendButton.isHidden = true
        }
    }
    
    func detectFriendList() {
        UserManager.shared.fetchFriendData(userId: currentUserId) { [weak self] result in
            switch result {
            case .success(let friend):
                //                self.friendList = friend
                //                self.detectInvitation()
                let friendId = friend.map { $0.userId }
                if friendId.contains(self?.friendData?.userId ?? "") {
                    self?.friendNameLabel.text = "你們已是好友"
                    self?.friendNameLabel.isHidden = false
                    self?.sendButton.isHidden = true
                } else {
                    self?.friendNameLabel.isHidden = false
                    self?.sendButton.isHidden = false
//                    self.detectInvitation()
                }
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
    }
    
    func detectInvitation() {
        FriendManager.shared.fetchReceiverInvitation(userId: currentUserId, friendId: self.friendData?.userId ?? "") { [weak self] result in
            switch result {
            case .success:
                self?.friendNameLabel.text = "對方已寄送好友邀請"
                self?.sendButton.isHidden = true
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
        FriendManager.shared.fetchSenderInvitation(userId: currentUserId, friendId: self.friendData?.userId ?? "") { [weak self] result in
            switch result {
            case .success:
                self?.friendNameLabel.text = "已寄送好友邀請"
                self?.sendButton.isHidden = true
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
    }
    
    @objc func pressSendButton() {
        FriendManager.shared.updateFriendInvitation(senderId: currentUserId, receiverId: self.friendData?.userId ?? "")
        self.friendData = nil
        sendButton.isHidden = true
        friendNameLabel.isHidden = true
    }
    
    func setScanQRCodeButtonConstraint() {
        scanQRCode.topAnchor.constraint(equalTo: friendTextField.bottomAnchor, constant: 10).isActive = true
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
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        if self.friendData == nil {
//            self.friendNameLabel.text = "無符合對象"
//            self.friendNameLabel.isHidden = false
//            self.sendButton.isHidden = true
//        }
//    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.friendData = nil
        friendNameLabel.text = ""
    }
}
