//
//  RemindersViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/20.
//

import UIKit

class RemindersViewController: UIViewController {

    var testButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        setTestButton()
        sendNotification()
    }
    
//    func setTestButton() {
//        view.addSubview(testButton)
//        testButton.translatesAutoresizingMaskIntoConstraints = false
//        testButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
//        testButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
//        testButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
//        testButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
//        testButton.setTitle("Send", for: .normal)
//        testButton.backgroundColor = .systemGray
//        testButton.addTarget(self, action: #selector(sendNotification), for: .touchUpInside)
//    }

//    @objc
    func sendNotification() {
        let content = UNMutableNotificationContent()
                content.title = "title：測試"
                content.subtitle = "subtitle：2022/04/20"
                content.body = "body：test test test test test test test test test"
                content.badge = 1
        content.sound = UNNotificationSound.default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                
                let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                    print("成功建立通知...")
                })
    }
}
