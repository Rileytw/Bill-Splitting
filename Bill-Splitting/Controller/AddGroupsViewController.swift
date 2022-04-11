//
//  ViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/8.
//

import UIKit

class AddGroupsViewController: UIViewController {
    
    let nameTextField = UITextField()
    let descriptionTextView = UITextView()
    
    let fullScreenSize = UIScreen.main.bounds.size
    var myTextField = UITextField()
    
    var pickerView: UIPickerView!
    var pickerViewData = ["個人預付", "多人支付"]
    
    var friendList = ["Joseph", "Amber"]
//    var filterDataList: [String] = [String]()
//    var searchedDataSource: [String] = ["Amber", "Joseph", "Cherry", "Coconut", "Durian", "Grape", "Grapefruit", "Guava", "Lemon"] // 被搜尋的資料集合
//    var isShowSearchResult: Bool = false // 是否顯示搜尋的結果
    
    let tableView = UITableView()
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTextField()
        setTextView()
        setUpPickerView(data: pickerViewData)
        
        setTextFieldOfPickerView()
        setTableView()
//        setSearchBar()
    }
    
    func setTextField() {
        nameTextField.borderStyle = UITextField.BorderStyle.roundedRect
        nameTextField.layer.borderColor = UIColor.black.cgColor
        nameTextField.layer.borderWidth = 1
        self.view.addSubview(nameTextField)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: nameTextField, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 100).isActive = true
        NSLayoutConstraint(item: nameTextField, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: (UIScreen.main.bounds.width)/3).isActive = true
        NSLayoutConstraint(item: nameTextField, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 2/3, constant: -20).isActive = true
        NSLayoutConstraint(item: nameTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 40).isActive = true
    }
    
    func setTextView() {
        descriptionTextView.layer.borderWidth = 1
        self.view.addSubview(descriptionTextView)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: descriptionTextView, attribute: .top, relatedBy: .equal, toItem: nameTextField, attribute: .top, multiplier: 1, constant: 100).isActive = true
        NSLayoutConstraint(item: descriptionTextView,attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: (UIScreen.main.bounds.width)/3).isActive = true
        
        NSLayoutConstraint(item: descriptionTextView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 2/3, constant: -20).isActive = true
        NSLayoutConstraint(item: descriptionTextView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 100).isActive = true
    }
    
    func setUpPickerView(data:[String]) {
        pickerViewData = data
        pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        //      pickerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 3)
        //      pickerView.center = view.center
        //      view.addSubview(pickerView)
    }
    
    func setTextFieldOfPickerView() {
        myTextField = UITextField(frame: CGRect(x: 0, y: 0, width: fullScreenSize.width, height: 60))
        myTextField.inputView = pickerView
        myTextField.text = pickerViewData[0]
        myTextField.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        myTextField.textAlignment = .center
        myTextField.center = CGPoint(x: fullScreenSize.width * 0.5, y: fullScreenSize.height * 0.5)
        self.view.addSubview(myTextField)
    }
    
    func setTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: myTextField.bottomAnchor, constant: 20).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        
        tableView.register(UINib(nibName: String(describing: AddGroupTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: AddGroupTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
    }
    
//    func setSearchBar() {
//        self.searchController = UISearchController(searchResultsController: nil)
//        self.searchController.searchBar.placeholder = "請輸入朋友名稱"
//        self.searchController.searchBar.sizeToFit()
//        self.searchController.searchResultsUpdater = self
//        self.searchController.searchBar.delegate = self
//        self.searchController.dimsBackgroundDuringPresentation = false
//        self.tableView.tableHeaderView = self.searchController.searchBar
//    }
}

extension AddGroupsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerViewData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        myTextField.text = pickerViewData[row]
    }
}

extension AddGroupsViewController: UITableViewDataSource, UITableViewDelegate,  UISearchResultsUpdating, UISearchBarDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//        if self.isShowSearchResult {
//                    // 若是有查詢結果則顯示查詢結果集合裡的資料
//                    return self.filterDataList.count
//                } else {
//                    return friendList.count
//                }
        return friendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: AddGroupTableViewCell.self),
            for: indexPath
        )
        
        guard let addGroupsCell = cell as? AddGroupTableViewCell else { return cell }
        
//        MARK: Add searchBar
//        if self.isShowSearchResult {
//                   addGroupsCell.textLabel?.text = String(filterDataList[indexPath.row])
//               } else {
//                   addGroupsCell.friendNameLabel.text = friendList[indexPath.row]
//               }
        addGroupsCell.friendNameLabel.text = friendList[indexPath.row]
        return addGroupsCell
    }
    
    func updateSearchResults(for searchController: UISearchController) {
//        if self.searchController.searchBar.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count == 0 {
//            return
//        }
//
//        self.filterDataSource()
    }
    
//    func filterDataSource() {
//        // 使用高階函數來過濾掉陣列裡的資料
//        self.filterDataList = searchedDataSource.filter({ (fruit) -> Bool in
//            return fruit.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil
//        })
//
//        if self.filterDataList.count > 0 {
//            self.isShowSearchResult = true
//            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.init(rawValue: 1)!
//        } else {
//            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none //
//        }
//
//        self.tableView.reloadData()
//    }
    
}
