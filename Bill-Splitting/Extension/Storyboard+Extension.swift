//
//  Storyboard+Extension.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/11.
//

import UIKit

private struct StoryboardCategory {

    static let main = "Main"

    static let groups = "Groups"

    static let reminders = "Reminders"

    static let addGroups = "AddGroups"
    
    static let records = "Records"

    static let profile = "Profile"
}

extension UIStoryboard {

    static var main: UIStoryboard { return stStoryboard(name: StoryboardCategory.main) }

    static var groups: UIStoryboard { return stStoryboard(name: StoryboardCategory.groups) }

    static var reminders: UIStoryboard { return stStoryboard(name: StoryboardCategory.reminders) }

    static var addGroups: UIStoryboard { return stStoryboard(name: StoryboardCategory.addGroups) }

    static var records: UIStoryboard { return stStoryboard(name: StoryboardCategory.records) }

    static var profile: UIStoryboard { return stStoryboard(name: StoryboardCategory.profile) }

    private static func stStoryboard(name: String) -> UIStoryboard {

        return UIStoryboard(name: name, bundle: nil)
    }
}
