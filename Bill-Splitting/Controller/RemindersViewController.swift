//
//  RemindersViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/20.
//

import UIKit
import Lottie

class RemindersViewController: BaseViewController {
    
    // MARK: - Property
    var tableView = UITableView()
    var emptyLabel = UILabel()
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
    var currentUserId: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        setEmptyLabel()
        setTableView()
        setAddButton()
        navigationItem.title = NavigationItemName.reminder.name
        setAnimation()
        getCurrentUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCurrentUserData()
        getReminders()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        addNotificationButton.layer.cornerRadius = 0.5 * addNotificationButton.bounds.size.width
        addNotificationButton.clipsToBounds = true
    }
    
    // MARK: - Method
    func getCurrentUser() {
        currentUserId = UserManager.shared.currentUser?.userId ?? ""
    }
    
    @objc func pressAddButton() {
        let storyBoard = UIStoryboard(name: StoryboardCategory.reminders, bundle: nil)
        guard let addReminderViewController = storyBoard.instantiateViewController(
            withIdentifier: AddReminderViewController.identifier
        ) as? AddReminderViewController else { return }
        
        if #available(iOS 15.0, *) {
            if let sheet = addReminderViewController.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.preferredCornerRadius = 20
            }
        }
        
        addReminderViewController.reminderInfo = { [weak self] _ in
            self?.getReminders()
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
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(notificationTime), repeats: false)
        let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
        })
    }
    
    func getReminders() {
        guard let currentUserId = currentUserId else { return }
        ReminderManager.shared.fetchReminders(currentUser: currentUserId) { [weak self] result in
            switch result {
            case .success(let reminders):
                self?.allReminders = reminders
                self?.reminders = reminders.filter { $0.status == RemindStatus.active.statusInt }
                self?.fetchReminderInfo()
                if self?.allReminders.isEmpty == true {
                    self?.emptyLabel.isHidden = false
                } else {
                    self?.emptyLabel.isHidden = true
                }
            case .failure:
                self?.showFailure(text: ErrorType.generalError.errorMessage)
            }
        }
    }
    
    private func updateReminderStatus() {
        for index in 0..<self.reminders.count {
            let remindTime = self.reminders[index].remindTime - Date().timeIntervalSince1970
            if remindTime < 0 {
                ReminderManager.shared.updateReminderStatus(documentId: reminders[index].documentId)
            }
        }
    }
    
    func fetchReminderInfo() {
        guard let currentUserId = currentUserId else { return }
        var isGetReminderSuccess: Bool = false
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            GroupManager.shared.fetchGroups(userId: currentUserId, status: 0) { [weak self] result in
                switch result {
                case .success(let groups):
                    self?.reminderGroups = groups
                    if self?.reminders.isEmpty == false {
                        for group in groups where group.groupId == self?.reminders[0].groupId {
                            self?.group = group
                        }
                    }
                    isGetReminderSuccess = true
                case .failure:
                    isGetReminderSuccess = false
                }
                group.leave()
            }
        }
        
        group.enter()
        DispatchQueue.global().async {
            UserManager.shared.fetchUsersData { [weak self] result in
                switch result {
                case .success(let users):
                    self?.members = users
                    self?.detectBlockListUser()
                    if self?.reminders.isEmpty == false {
                        for user in users where user.userId == self?.reminders[0].memberId {
                            self?.member = user
                        }
                    }
                    isGetReminderSuccess = true
                case .failure:
                    isGetReminderSuccess = false
                }
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) { [weak self] in
            if isGetReminderSuccess {
                if self?.reminders.isEmpty == false {
                    self?.updateReminderStatus()
                    
                    let activeReminders = self?.getActiveReminder()
                    if activeReminders?.isEmpty == false {
                        guard let activeReminder = activeReminders?[0],
                              let notifyGroup = self?.getNotifyGroup(activeReminder: activeReminder),
                              let memberName = self?.getNotifyMember(activeReminder: activeReminder).userName
                        else { return }
                        self?.setLocalReminder(activeReminder, memberName, notifyGroup)
                    }
                }
                self?.tableView.reloadData()
                self?.removeAnimation()
                
                guard let reminders = self?.reminders else { return }
                self?.updateReminderStatus(reminders)
            } else {
                self?.showFailure(text: ErrorType.dataFetchError.errorMessage)
            }
        }
    }
    
    private func setLocalReminder(
        _ activeReminder: Reminder, _ memberName: String, _ notifyGroup: GroupData) {
            reminderTitle = notifyGroup.groupName
            getReminderContent(activeReminder, memberName)
            notificationTime = activeReminder.remindTime - Date().timeIntervalSince1970
            sendNotification()
        }
    
    private func getNotifyGroup(activeReminder: Reminder) -> GroupData {
        var notifyGroup: GroupData?
        for group in reminderGroups where group.groupId == activeReminder.groupId {
            notifyGroup = group
        }
        return notifyGroup ?? GroupData()
    }
    
    private func getNotifyMember(activeReminder: Reminder) -> UserData {
        var notifyMember: UserData?
        for user in members where user.userId == activeReminder.memberId {
            notifyMember = user
        }
        return notifyMember ?? UserData()
    }
    
    private func getActiveReminder() -> [Reminder] {
        var activeReminders = reminders.filter { ($0.remindTime - Date().timeIntervalSince1970) > 0 }
        activeReminders.sort { $0.remindTime < $1.remindTime }
        return activeReminders
    }
    
    private func getReminderContent(_ activeReminder: Reminder, _ memberName: String) {
        switch activeReminder.type {
        case .credit:
            reminderSubtitle = RemindType.credit.textInfo
            remindBody = "記得向" + memberName + "請款"
        case .debt:
            reminderSubtitle = RemindType.debt.textInfo
            remindBody = "記得付錢給" + memberName
        }
    }
    
    private func updateReminderStatus(_ reminders: [Reminder]) {
        for index in 0..<reminders.count {
            let remindTime = reminders[index].remindTime - Date().timeIntervalSince1970
            if remindTime < 0 && reminders[index].status == RemindStatus.active.statusInt {
                ReminderManager.shared.updateReminderStatus(documentId: reminders[index].documentId)
            }
        }
    }
    
    func fetchCurrentUserData() {
        guard let currentUserId = currentUserId else { return }
        UserManager.shared.fetchUserData(friendId: currentUserId) { [weak self] result in
            if case .failure = result {
                self?.showFailure(text: ErrorType.generalError.errorMessage)
            }
        }
    }
    
    func detectBlockListUser() {
        guard let blockList = UserManager.shared.currentUser?.blackList else { return }
        let newUserData = UserManager.renameBlockedUser(blockList: blockList,
                                                        userData: members)
        members = newUserData
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
        
        reminderCell.createReminderCell(member: memberName ?? "",
                                        type: type.rawValue,
                                        groupName: groupName ?? "", time: time)
        
        return reminderCell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
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

extension RemindersViewController {
    func setTableView() {
        view.addSubview(tableView)
        setTableViewConstraint()
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.register(UINib(nibName: String(describing: ReminderTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: ReminderTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
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
        addNotificationButton.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        addNotificationButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        addNotificationButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        addNotificationButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    func setEmptyLabel() {
        view.addSubview(emptyLabel)
        emptyLabel.text = "目前暫無資料，點擊右下 + 新增提醒"
        emptyLabel.textColor = .greenWhite
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        emptyLabel.widthAnchor.constraint(equalToConstant: 300).isActive = true
        emptyLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        emptyLabel.isHidden = true
    }
    
    func setAddButton() {
        view.addSubview(addNotificationButton)
        setAddButtonConstraints()
        addNotificationButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addNotificationButton.tintColor = .white
        addNotificationButton.backgroundColor = .systemGray
        addNotificationButton.addTarget(self, action: #selector(pressAddButton), for: .touchUpInside)
        ElementsStyle.styleSpecificButton(addNotificationButton)
    }
}
