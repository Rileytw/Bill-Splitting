//
//  RemindersViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/20.
//

import UIKit

class RemindersViewController: UIViewController {

    var addNotificationButton = UIButton()
    var notificationTime = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setAddButton()
//        sendNotification()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        addNotificationButton.layer.cornerRadius = 0.5 * addNotificationButton.bounds.size.width
        addNotificationButton.clipsToBounds = true
    }
    
    func setAddButton() {
        view.addSubview(addNotificationButton)
        setAddButtonConstraints()
        addNotificationButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addNotificationButton.tintColor = .white
        addNotificationButton.backgroundColor = .systemGray
        addNotificationButton.addTarget(self, action: #selector(pressAddButton), for: .touchUpInside)
    }

    @objc func pressAddButton() {
        let storyBoard = UIStoryboard(name: "Reminders", bundle: nil)
        guard let addReminderViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: AddReminderViewController.self)) as? AddReminderViewController else { return }
        
        if #available(iOS 15.0, *) {
                if let sheet = addReminderViewController.sheetPresentationController {
                    sheet.detents = [.medium()]
                    sheet.preferredCornerRadius = 20
                }
            }
        self.present(addReminderViewController, animated: true, completion: nil)
    }
    
    func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "title：測試"
        content.subtitle = "subtitle：2022/04/20"
        content.body = "body：test test test test test test test test test"
//        content.badge = 1
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(notificationTime), repeats: false)
        
        let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            print("成功建立通知...")
        })
    }
    
    func setAddButtonConstraints() {
        addNotificationButton.translatesAutoresizingMaskIntoConstraints = false
        addNotificationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        addNotificationButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        addNotificationButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        addNotificationButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
}
