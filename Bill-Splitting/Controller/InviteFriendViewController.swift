//
//  InviteFriendViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/12.
//

import UIKit

class InviteFriendViewController: UIViewController {
    
    let friendTextField = UITextField()
    let searchButton = UIButton()
    let friendNameLabel = UILabel()
    let sendButton = UIButton()
    var friendName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTextField()
        setSearchButton()
        setSearchResult()
    }
    
    func setTextField() {
        let nameLabel = UILabel()
        nameLabel.text = "寄送好友邀請"
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: nameLabel, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 100).isActive = true
        NSLayoutConstraint(item: nameLabel, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: nameLabel, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 2/3, constant: -20).isActive = true
        NSLayoutConstraint(item: nameLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 40).isActive = true
        
        friendTextField.borderStyle = UITextField.BorderStyle.roundedRect
        friendTextField.layer.borderColor = UIColor.black.cgColor
        friendTextField.layer.borderWidth = 1
        self.view.addSubview(friendTextField)
        friendTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: friendTextField, attribute: .top, relatedBy: .equal, toItem: nameLabel, attribute: .bottom, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: friendTextField, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: friendTextField, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 2/3, constant: 0).isActive = true
        NSLayoutConstraint(item: friendTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 40).isActive = true
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
        
        searchButton.addTarget(self, action: #selector(pressSearchButton), for: .touchUpInside)
    }
    
    func setSearchResult() {
        sendButton.setTitle("寄送", for: .normal)
        sendButton.backgroundColor = .systemGray
        view.addSubview(sendButton)
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.heightAnchor.constraint(equalTo: searchButton.heightAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalTo: searchButton.widthAnchor).isActive = true
        sendButton.centerXAnchor.constraint(equalTo: searchButton.centerXAnchor).isActive = true
        sendButton.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 100).isActive = true
        
        friendNameLabel.text = friendName
        view.addSubview(friendNameLabel)
        friendNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        friendNameLabel.topAnchor.constraint(equalTo: friendTextField.bottomAnchor, constant: 100).isActive = true
        friendNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        friendNameLabel.widthAnchor.constraint(equalTo: friendTextField.widthAnchor).isActive = true
        friendNameLabel.heightAnchor.constraint(equalTo: friendTextField.heightAnchor).isActive = true
    }
    
//    @objc func pressSearchButton() {
//        
//    }
}
