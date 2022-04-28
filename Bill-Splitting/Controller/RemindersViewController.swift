//
//  RemindersViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/20.
//

import UIKit

class RemindersViewController: UIViewController {
    
    let currentUserId = AccountManager.shared.currentUser.currentUserId
    var addNotificationButton = UIButton()
    var notificationTime: Double?
    var reminders = [Reminder]()
    var allReminders = [Reminder]()
    var group: GroupData?
    var reminderGroups: [GroupData] = []
    var member: UserData?
    var members: [UserData] = []
    var reminderTitle: String?
    var reminderSubtitle: String?
    var remindBody: String?
    
    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
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
        //        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
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
                self?.allReminders = reminders
                self?.reminders = reminders.filter { $0.status == RemindStatus.active.statusInt }
                self?.fetchReminderInfo()
            case .failure(let error):
                print("Error decoding reminders: \(error)")
            }
        }
    }
    
    func fetchReminderInfo() {
        let group = DispatchGroup()
        let firstQueue = DispatchQueue(label: "firstQueue", qos: .default, attributes: .concurrent)
        group.enter()
        firstQueue.async(group: group) {
            GroupManager.shared.fetchGroups(userId: self.currentUserId, status: 0) { [weak self] result in
                switch result {
                case .success(let groups):
                    self?.reminderGroups = groups
                    if self?.reminders.isEmpty == false {
                        for group in groups where group.groupId == self?.reminders[0].groupId {
                            self?.group = group
                        }
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
                    self?.members = users
                    if self?.reminders.isEmpty == false {
                        for user in users where user.userId == self?.reminders[0].memberId {
                            self?.member = user
                        }
                    }
                case .failure(let error):
                    print("Error decoding users: \(error)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            if self.reminders.isEmpty == false {
                guard let member = self.member else { return }
                let remindTimeInterval = self.reminders[0].remindTime - Date().timeIntervalSince1970
                self.reminderTitle = self.group?.groupName
                if self.reminders[0].type == RemindType.credit.intData {
                    self.reminderSubtitle = RemindType.credit.textInfo
                    self.remindBody = "記得向" + member.userName + "請款"
                } else {
                    self.reminderSubtitle = RemindType.debt.textInfo
                    self.remindBody = "記得付錢給" + member.userName
                }
                self.notificationTime = self.reminders[0].remindTime - Date().timeIntervalSince1970
                
                if self.reminders.isEmpty == false && remindTimeInterval > 0 {
                    self.sendNotification()
                    //  MARK: - Bug of reminders overlap when setting multiple reminders
                    ReminderManager.shared.updateReminderStatus(documentId: self.reminders[0].documentId)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    func setTableView() {
        view.addSubview(tableView)
        setTableViewConstraint()
        tableView.register(UINib(nibName: String(describing: ReminderTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ReminderTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        //        tableView.isEditing = true
    }
    
    func setTableViewConstraint() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 10).isActive = true
    }
    
    func setAddButtonConstraints() {
        addNotificationButton.translatesAutoresizingMaskIntoConstraints = false
        addNotificationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        addNotificationButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        addNotificationButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        addNotificationButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
}

extension RemindersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allReminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ReminderTableViewCell.self),
            for: indexPath)
        guard let reminderCell = cell as? ReminderTableViewCell else { return cell }
        
        var memberName: String?
        var groupName: String?
        for group in reminderGroups where group.groupId == allReminders[indexPath.row].groupId {
            groupName = group.groupName
        }
        for member in members where member.userId == allReminders[indexPath.row].memberId {
            memberName = member.userName
        }
        let time = allReminders[indexPath.row].remindTime
        let type = allReminders[indexPath.row].type
        
        reminderCell.createReminderCell(member: memberName ?? "", type: type, groupName: groupName ?? "", time: time)
        
        return reminderCell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            // delete the item here
            ReminderManager.shared.deleteReminder(documentId: self.allReminders[indexPath.row].documentId)
            self.allReminders.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}
