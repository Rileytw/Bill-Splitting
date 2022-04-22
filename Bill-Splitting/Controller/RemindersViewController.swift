//
//  RemindersViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/20.
//

import UIKit

class RemindersViewController: UIViewController {

    var addNotificationButton = UIButton()
    var notificationTime: Double?
    var reminders = [Reminder]()
    var group: GroupData?
    var member: UserData?
    var reminderTitle: String?
    var reminderSubtitle: String?
    var remindBody: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAddButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getReminders()
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
        guard let reminderTitle = reminderTitle,
              let reminderSubtitle = reminderSubtitle,
              let reminderBody = remindBody,
              let notificationTime = notificationTime
        else { return }

        let content = UNMutableNotificationContent()
        content.title = reminderTitle
        content.subtitle = reminderSubtitle
        content.body = reminderBody
//        content.badge = 1
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(notificationTime), repeats: false)
        let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            print("成功建立通知...")
        })
    }
    
    func getReminders() {
        ReminderManager.shared.fetchReminders { [weak self] result in
            switch result {
            case .success(let reminders):
                self?.reminders = reminders
                self?.fetchReminderInfo()
            case .failure(let error):
                print("Error decoding reminders: \(error)")
            }
        }
    }
    
    func fetchReminderInfo() {
        let group = DispatchGroup()
        let remindTimeInterval = self.reminders[0].remindTime - Date().timeIntervalSince1970
        
        if self.reminders.isEmpty == false && remindTimeInterval > 0 {
            let firstQueue = DispatchQueue(label: "firstQueue", qos: .default, attributes: .concurrent)
            group.enter()
            firstQueue.async(group: group) {
                GroupManager.shared.fetchGroups(userId: userId) { [weak self] result in
                    switch result {
                    case .success(let groups):
                        for group in groups where group.groupId == self?.reminders[0].groupId {
                            self?.group = group
                        }
                    case .failure(let error):
                        print("Error decoding groups: \(error)")
                    }
                    group.leave()

                }
            }
            
            let secondQueue = DispatchQueue(label: "secondQueue", qos: .default, attributes: .concurrent)
            group.enter()
            secondQueue.async(group: group) {
                UserManager.shared.fetchUsersData { [weak self] result in
                    switch result {
                    case .success(let users):
                        for user in users where user.userId == self?.reminders[0].memberId {
                            self?.member = user
                        }
                    case .failure(let error):
                        print("Error decoding users: \(error)")
                    }
        
                    group.leave()
                }
                
            }
            
            group.notify(queue: DispatchQueue.main) {
                guard let member = self.member else { return }
                self.reminderTitle = self.group?.groupName
                if self.reminders[0].type == RemindType.credit.intData {
                    self.reminderSubtitle = RemindType.credit.textInfo
                    self.remindBody = "記得向" + member.userName + "請款"
                } else {
                    self.reminderSubtitle = RemindType.debt.textInfo
                    self.remindBody = "記得付錢給" + member.userName
                }
                self.notificationTime = self.reminders[0].remindTime - Date().timeIntervalSince1970
                
                self.sendNotification()
                
                ReminderManager.shared.updateReminderStatus(documentId: self.reminders[0].documentId)
            }
        }
    }
    
    func setAddButtonConstraints() {
        addNotificationButton.translatesAutoresizingMaskIntoConstraints = false
        addNotificationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        addNotificationButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        addNotificationButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        addNotificationButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
}
