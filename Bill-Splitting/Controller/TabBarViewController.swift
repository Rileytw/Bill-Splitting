//
//  TabBarViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/11.
//

import UIKit

private enum Tab {
    case groups
    case reminders
    case addGroups
    case records
    case profile
    
    func viewController() -> UIViewController {
        var viewController: UIViewController
        
        switch self {
        case .groups:
            viewController = UIStoryboard.groups.instantiateInitialViewController()!
        case .reminders:
            viewController = UIStoryboard.reminders.instantiateInitialViewController()!
        case .addGroups:
            viewController = UIStoryboard.addGroups.instantiateInitialViewController()!
        case .records:
            viewController = UIStoryboard.records.instantiateInitialViewController()!
        case .profile:
            viewController = UIStoryboard.profile.instantiateInitialViewController()!
        }
        
        viewController.tabBarItem = tabBarItem()

        return viewController
    }
    
    func tabBarItem() -> UITabBarItem {
        switch self {
        case .groups:
            return UITabBarItem(title: "我的群組", image: UIImage(systemName: "person.3"),
                                selectedImage: UIImage(systemName: "person.3.fill")
            )
        case .reminders:
            return UITabBarItem(title: "設定提醒", image: UIImage(systemName: "bell"),
                                selectedImage: UIImage(systemName: "bell.fill")
            )
        case .addGroups:
            return UITabBarItem(title: "新增群組", image: UIImage(systemName: "plus.square"),
                                selectedImage: UIImage(systemName: "plus.square.fill")
            )
        case .records:
            return UITabBarItem(title: "近期紀錄", image: UIImage(systemName: "list.bullet.rectangle"),
                                selectedImage: UIImage(systemName: "list.bullet.rectangle.fill")
            )
        case .profile:
            return UITabBarItem(title: "個人檔案", image: UIImage(systemName: "person"),
                                selectedImage: UIImage(systemName: "person.fill")
            )
        }
    }
}

class TabBarViewController: UITabBarController {
    
    private let tabs: [Tab] = [.groups, .reminders, .addGroups, .records, .profile]
    
    var allTabBatItem: UITabBarItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = tabs.map({ $0.viewController() })
        self.tabBar.tintColor = .selectedColor
        self.tabBar.barTintColor = .styleBlue
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .styleBlue
            
            self.tabBar.standardAppearance = appearance
            self.tabBar.scrollEdgeAppearance = appearance
        }
    }
}
