//
//  GroupsView.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/13.
//

import UIKit

class GroupsView: UIView {
    
    @IBOutlet weak var searchGroupTextField: UITextField!
    
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var allGroupsButton: UIButton!
    
    @IBOutlet weak var multipleUsersTypeButton: UIButton!
    
    @IBOutlet weak var personalUserTypeButton: UIButton!
    
    @IBOutlet weak var closedGroupsButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadXib()
    }
    
    func loadXib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: GroupsView.self), bundle: bundle)

        guard let xibView = nib.instantiate(withOwner: self, options: nil)[0] as? UIView else { return }

        addSubview(xibView)

        xibView.translatesAutoresizingMaskIntoConstraints = false
        xibView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        xibView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        xibView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        xibView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
//        if let loadingView = Bundle(for: GroupsView.self).loadNibNamed("\(GroupsView.self)", owner: nil, options: nil)?.first as? UIView {
//              addSubview(loadingView)
//              loadingView.frame = bounds
//           }
    }
}
