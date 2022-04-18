//
//  SubscribeViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/17.
//

import UIKit

class SubscribeViewController: UIViewController {
    
    var startTimeDatePicker = UIDatePicker()
    var endTimeDatePicker = UIDatePicker()
    
    var startTimeLabel = UILabel()
    var endTimeLabel = UILabel()
    var cycleLabel = UILabel()
    var completeButton = UIButton()
    
    var cyclePicker = BasePickerViewInTextField(frame: .zero)
    var cycle = ["每週", "每月", "每年"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLabel()
        setDatePicker()
        setCyclePicker()
        setCompleteButton()
    }
    
    func setLabel() {
        view.addSubview(startTimeLabel)
        startTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        startTimeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        startTimeLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        startTimeLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        startTimeLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        startTimeLabel.text = "開始時間"
        startTimeLabel.font = startTimeLabel.font.withSize(16)
        
        view.addSubview(endTimeLabel)
        endTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        endTimeLabel.topAnchor.constraint(equalTo: startTimeLabel.bottomAnchor, constant: 140).isActive = true
        endTimeLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        endTimeLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        endTimeLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        endTimeLabel.text = "結束時間"
        endTimeLabel.font = endTimeLabel.font.withSize(16)
        
        view.addSubview(cycleLabel)
        cycleLabel.translatesAutoresizingMaskIntoConstraints = false
        cycleLabel.topAnchor.constraint(equalTo: endTimeLabel.bottomAnchor, constant: 140).isActive = true
        cycleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        cycleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        cycleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        cycleLabel.text = "週期"
        cycleLabel.font = endTimeLabel.font.withSize(16)
        
    }
    
    func setDatePicker() {
        view.addSubview(startTimeDatePicker)
        startTimeDatePicker.translatesAutoresizingMaskIntoConstraints = false
        startTimeDatePicker.topAnchor.constraint(equalTo: startTimeLabel.bottomAnchor, constant: 20).isActive = true
        startTimeDatePicker.heightAnchor.constraint(equalToConstant: 80).isActive = true
        startTimeDatePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant:  -20).isActive = true
        startTimeDatePicker.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        startTimeDatePicker.locale = Locale(identifier: "zh_Hant_TW")
        
        view.addSubview(endTimeDatePicker)
        endTimeDatePicker.translatesAutoresizingMaskIntoConstraints = false
        endTimeDatePicker.topAnchor.constraint(equalTo: endTimeLabel.bottomAnchor, constant: 20).isActive = true
        endTimeDatePicker.heightAnchor.constraint(equalToConstant: 80).isActive = true
        endTimeDatePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -20).isActive = true
        endTimeDatePicker.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        endTimeDatePicker.locale = Locale(identifier: "zh_Hant_TW")
    }
    
    func setCyclePicker() {
        view.addSubview(cyclePicker)
        cyclePicker.translatesAutoresizingMaskIntoConstraints = false
        cyclePicker.topAnchor.constraint(equalTo: cycleLabel.bottomAnchor, constant: 20).isActive = true
        cyclePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
//        cyclePicker.widthAnchor.constraint(equalToConstant: 40).isActive = true
//        cyclePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -40).isActive = true
        cyclePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        cyclePicker.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        cyclePicker.pickerView.dataSource = self
        cyclePicker.pickerView.delegate = self
    }
    
    func setCompleteButton() {
        view.addSubview(completeButton)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        completeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        completeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        completeButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        completeButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        completeButton.setTitle("設定", for: .normal)
        completeButton.backgroundColor = .systemTeal
        completeButton.addTarget(self, action: #selector(pressCompleteButton), for: .touchUpInside)
    }
    
    @objc func pressCompleteButton() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SubscribeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cycle.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cycle[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        return cyclePicker.textField.text = cycle[row]
    }
}
