//
//  AddMoreInfoViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/20.
//

import UIKit
import Lottie
import SwiftUI

class AddMoreInfoViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    // MARK: - Property
    var photoImageView = UIImageView()
    var addPhotoButton = UIButton()
    var addPhotoLabel = UILabel()
    var completeButton = UIButton()
    var descriptionLabel = UILabel()
    let dismissButton = UIButton()
    var descriptionTextView = UITextView()
    let imagePickerController = UIImagePickerController()
    var selectedImage: UIImage?
    private var animationView = AnimationView()
    
    let currentUserId = UserManager.shared.currentUser?.userId ?? ""
    var isItemExist: Bool = false
    var itemData: ItemData?
    
    typealias UrlData = (String) -> Void
    var urlData: UrlData?
    
    typealias Description = (String) -> Void
    var itemDescription: Description?
    
    typealias ImageData = (UIImage) -> Void
    var itemImage: ImageData?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        setCompleteButton()
        setDescription()
        setAddPhotoLabel()
        setAddPhotoButton()
        setPhotoImageView()
        setDismissButton()
        imagePickerController.delegate = self
        
    }
    
    // MARK: - Method
    @objc func pressUploadPhoto() {
        let imagePickerAlertController = UIAlertController(title: "上傳照片",
                                                           message: "拍攝或上傳照片",
                                                           preferredStyle: .actionSheet)
        let libraryAction = UIAlertAction(title: "照片", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                self.imagePickerController.sourceType = .photoLibrary
                self.present(self.imagePickerController, animated: true, completion: nil)
            }
        }
        
        let cameraAction = UIAlertAction(title: "相機", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePickerController.sourceType = .camera
                self.present(self.imagePickerController, animated: true, completion: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
            imagePickerAlertController.dismiss(animated: true, completion: nil)
        }
        
        imagePickerAlertController.addAction(cameraAction)
        imagePickerAlertController.addAction(libraryAction)
        imagePickerAlertController.addAction(cancelAction)
        present(imagePickerAlertController, animated: true, completion: nil)
        
        // MARK: - code for iPad to avoid crash
        imagePickerAlertController.popoverPresentationController?.sourceView = self.view
        
        let xOrigin = self.view.bounds.width / 2
        
        let popoverRect = CGRect(x: xOrigin, y: 0, width: 1, height: 1)
        
        imagePickerAlertController.popoverPresentationController?.sourceRect = popoverRect
        
        imagePickerAlertController.popoverPresentationController?.permittedArrowDirections = .up
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController,
                                        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            self.photoImageView.image = pickedImage
            selectedImage = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func pressComplete() {
        setAnimation()
        itemDescription?(self.descriptionTextView.text)
        if isItemExist == true {
            if selectedImage == nil {
                self.urlData?(itemData?.itemImage ?? "")
                self.dismiss(animated: true, completion: nil)
            } else {
                itemImage?(self.selectedImage ?? UIImage())
                self.dismiss(animated: true, completion: nil)
            }
        } else if selectedImage != nil && isItemExist == false {
            itemImage?(self.selectedImage ?? UIImage())
            self.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func setAnimation() {
        let mask = UIView()
        view.stickSubView(mask)
        mask.backgroundColor = .maskBackgroundColor
        
        animationView = .init(name: "upload")
        view.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        animationView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        animationView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        
        animationView.play()
    }
    
    func setDescription() {
        view.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.topAnchor.constraint(equalTo: completeButton.bottomAnchor, constant: 20).isActive = true
        descriptionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        descriptionLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
        descriptionLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        descriptionLabel.text = "詳細說明"
        descriptionLabel.textColor = UIColor.greenWhite
        
        view.addSubview(descriptionTextView)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20).isActive = true
        descriptionTextView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        descriptionTextView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        descriptionTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.selectedColor.cgColor
        descriptionTextView.backgroundColor = .clear
        descriptionTextView.textColor = UIColor.greenWhite
        descriptionTextView.font = UIFont.systemFont(ofSize: 16)
        descriptionTextView.layer.cornerRadius = 10
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 0)
        
        if isItemExist == true {
            descriptionTextView.text = itemData?.itemDescription
        }
    }
    
    func setDismissButton() {
        view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        dismissButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.tintColor = UIColor.greenWhite
        dismissButton.addTarget(self, action: #selector(pressDismiss), for: .touchUpInside)
    }
    
    @objc func pressDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setAddPhotoLabel() {
        view.addSubview(addPhotoLabel)
        addPhotoLabel.translatesAutoresizingMaskIntoConstraints = false
        addPhotoLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 40).isActive = true
        addPhotoLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        addPhotoLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        addPhotoLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        addPhotoLabel.textColor = UIColor.greenWhite
        addPhotoLabel.text = "新增照片"
    }
    
    func setAddPhotoButton() {
        view.addSubview(addPhotoButton)
        addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        addPhotoButton.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 40).isActive = true
        addPhotoButton.leftAnchor.constraint(equalTo: addPhotoLabel.rightAnchor, constant: 20).isActive = true
        addPhotoButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        addPhotoButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        addPhotoButton.setImage(UIImage(systemName: "camera"), for: .normal)
        addPhotoButton.setTitle("上傳", for: .normal)
        addPhotoButton.setTitleColor(UIColor.greenWhite, for: .normal)
        addPhotoButton.tintColor = UIColor.greenWhite
        addPhotoButton.addTarget(self, action: #selector(pressUploadPhoto), for: .touchUpInside)
        ElementsStyle.styleSpecificButton(addPhotoButton)
    }
    
    func setPhotoImageView() {
        view.addSubview(photoImageView)
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: 10).isActive = true
        photoImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        photoImageView.widthAnchor.constraint(equalToConstant: UIScreen.width - 40).isActive = true
        photoImageView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        
        photoImageView.contentMode = .scaleAspectFit
        photoImageView.layer.borderColor = UIColor.selectedColor.cgColor
        photoImageView.layer.borderWidth = 1
        photoImageView.layer.cornerRadius = 10
        
        if isItemExist == true {
            let image = itemData?.itemImage
            photoImageView.getImage(image, placeHolder: nil)
        }
    }
    
    func setCompleteButton() {
        view.addSubview(completeButton)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        completeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        completeButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        completeButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        
        completeButton.setTitle("儲存", for: .normal)
        completeButton.addTarget(self, action: #selector(pressComplete), for: .touchUpInside)
        ElementsStyle.styleSpecificButton(completeButton)
    }
}
