//
//  TabBarViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/11.
//

import UIKit

private enum Tab {
    case groups
//    case reminders
    case addGroups
//    case records
    case profile
    
    func viewController() -> UIViewController {
        var viewController: UIViewController
        
        switch self {
        case .groups:
            viewController = UIStoryboard.groups.instantiateInitialViewController()!
        case .addGroups:
            viewController = UIStoryboard.addGroups.instantiateInitialViewController()!
        case .profile:
            viewController = UIStoryboard.profile.instantiateInitialViewController()!
        }
        
        viewController.tabBarItem = tabBarItem()
//        viewController.tabBarItem
        
        return viewController
    }
    
    func tabBarItem() -> UITabBarItem {
        switch self {
        case .groups:
            return UITabBarItem(title: "groups", image: UIImage(systemName: "person.3"), selectedImage: UIImage(systemName: "person.3.fill")
            )
        case .addGroups:
            return UITabBarItem(title: "add groups", image: UIImage(systemName: "plus.square"), selectedImage: UIImage(systemName: "plus.square.fill")
            )
        case .profile:
            return UITabBarItem(title: "profile", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill")
            )
        }
    }
}

class TabBarViewController: UITabBarController {
    
    private let tabs:[Tab] = [.groups, .addGroups, .profile]
    
    var allTabBatItem: UITabBarItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = tabs.map({ $0.viewController() })
    }
    
}