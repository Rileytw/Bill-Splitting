//
//  AddItemViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/14.
//

import UIKit

class AddItemViewController: UIViewController {

    let addItemView = AddItemView(frame: .zero)
    let typePickerView = BasePickerViewInTextField(frame: .zero)
    var typePickerViewData = ["平分", "按比例", "自訂"]
    var memberPickerView = BasePickerViewInTextField(frame: .zero)
    let addButton = UIButton()
    
    var groupData: GroupData? 
    var memberId: [String]?
    var memberName: [String]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setAddItemView()
        setTypePickerView()
        setmemberPickerView()
        setAddButton()
    }

    func setAddItemView() {
        view.addSubview(addItemView)
        addItemView.translatesAutoresizingMaskIntoConstraints = false
        addItemView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        addItemView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        addItemView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        addItemView.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }

    func setTypePickerView() {
        view.addSubview(typePickerView)
        typePickerView.translatesAutoresizingMaskIntoConstraints = false
        typePickerView.topAnchor.constraint(equalTo: addItemView.bottomAnchor, constant: 20).isActive = true
        typePickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        typePickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        typePickerView.heightAnchor.constraint(equalToConstant: 100).isActive = true

        typePickerView.pickerView.dataSource = self
        typePickerView.pickerView.delegate = self
        typePickerView.pickerViewData = self.typePickerViewData
        
        typePickerView.pickerView.tag = 0
    }
    
    func setmemberPickerView() {
        view.addSubview(memberPickerView)
        memberPickerView.translatesAutoresizingMaskIntoConstraints = false
        memberPickerView.topAnchor.constraint(equalTo: typePickerView.bottomAnchor, constant: 20).isActive = true
        memberPickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        memberPickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        memberPickerView.heightAnchor.constraint(equalToConstant: 100).isActive = true

        memberPickerView.pickerView.dataSource = self
        memberPickerView.pickerView.delegate = self
        memberPickerView.pickerViewData = self.memberName ?? [""]
        
        memberPickerView.pickerView.tag = 1
    }
    
    func setAddButton() {
        view.addSubview(addButton)
        addButton.setTitle("完成", for: .normal)
        addButton.backgroundColor = .systemGray
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
}

extension AddItemViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return typePickerViewData.count
        } else {
            return memberName?.count ?? 1
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return typePickerViewData[row]
        } else {
            return memberName?[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            return typePickerView.textField.text = typePickerViewData[row]
        } else {
            return memberPickerView.textField.text = memberName?[row]
        }
    }
}
