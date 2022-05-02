//
//  BaseViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/2.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        UINavigationBar.appearance().backgroundColor = .black // backgorund color with gradient
        // or
        UINavigationBar.appearance().barTintColor = .greenWhite  // solid color
        
//        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.greenWhite]
//        self.navigationController?.navigationBar.tintColor = UIColor.greenWhite
            
        UIBarButtonItem.appearance().tintColor = .magenta
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.greenWhite]
        UITabBar.appearance().barTintColor = .yellow
    }
    
}
