//
//  AddMoreInfoViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/20.
//

import UIKit

class AddMoreInfoViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var photoImageView = UIImageView()
    var addPhotoButton = UIButton()
    var addPhotoLabel = UILabel()
    var completeButton = UIButton()
    var descriptionLabel = UILabel()
    var descriptionImage = UIButton()
    var descriptionTextView = UITextView()
    let imagePickerController = UIImagePickerController()
    var selectedImage: UIImage?
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    var isItemExist: Bool = false
    var itemData: ItemData?
    
    typealias UrlData = (String) -> Void
    var urlData: UrlData?
    
    typealias Description = (String) -> Void
    var itemDescription: Description?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setAddPhotoButton()
        setAddPhotoLabel()
        setPhotoImageView()
        setDescription()
        setCompleteButton()
        imagePickerController.delegate = self
        
    }
    
    func setAddPhotoLabel() {
        view.addSubview(addPhotoLabel)
        addPhotoLabel.translatesAutoresizingMaskIntoConstraints = false
        addPhotoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
        addPhotoLabel.leftAnchor.constraint(equalTo: addPhotoButton.rightAnchor, constant: 10).isActive = true
        addPhotoLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        addPhotoLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        addPhotoLabel.text = "上傳照片"
    }
    
    func setAddPhotoButton() {
        view.addSubview(addPhotoButton)
        addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        addPhotoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
        addPhotoButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        addPhotoButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        addPhotoButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        addPhotoButton.setImage(UIImage(systemName: "camera"), for: .normal)
        addPhotoButton.tintColor = .systemBlue
        addPhotoButton.addTarget(self, action: #selector(pressUploadPhoto), for: .touchUpInside)
    }
    
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
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            self.photoImageView.image = pickedImage
            selectedImage = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func setPhotoImageView() {
        view.addSubview(photoImageView)
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: 10).isActive = true
        photoImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        photoImageView.widthAnchor.constraint(equalToConstant: width - 40).isActive = true
        photoImageView.heightAnchor.constraint(equalToConstant: height/3).isActive = true
        
        photoImageView.contentMode = .scaleAspectFit
        
        if isItemExist == true {
            let image = itemData?.itemImage
            photoImageView.getImage(image, placeHolder: nil)
        }
    }
    
    func setCompleteButton() {
        view.addSubview(completeButton)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        completeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
        completeButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        completeButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        completeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        completeButton.setTitle("完成", for: .normal)
        completeButton.backgroundColor = .systemGray
        completeButton.addTarget(self, action: #selector(pressComplete), for: .touchUpInside)
    }
    
    @objc func pressComplete() {
        itemDescription?(self.descriptionTextView.text)
        
//        guard let selectedImage = selectedImage else { return }
//        let fileName = "\(userId)" + "\(Date())"
//        ImageManager.shared.uploadImageToStorage(image: selectedImage, fileName: fileName) { urlString in
//            self.urlData?(urlString)
//            self.dismiss(animated: true, completion: nil)
//        }
        getImageURL()
        
        if isItemExist == true {
            if selectedImage == nil {
                self.urlData?(itemData?.itemImage ?? "")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func getImageURL() {
        guard let selectedImage = selectedImage else { return }
        let fileName = "\(userId)" + "\(Date())"
        ImageManager.shared.uploadImageToStorage(image: selectedImage, fileName: fileName) { urlString in
            self.urlData?(urlString)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func setDescription() {
        view.addSubview(descriptionImage)
        descriptionImage.translatesAutoresizingMaskIntoConstraints = false
        descriptionImage.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 20).isActive = true
        descriptionImage.leftAnchor.constraint(equalTo: addPhotoButton.leftAnchor, constant: 0).isActive = true
        descriptionImage.widthAnchor.constraint(equalToConstant: 40).isActive = true
        descriptionImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
        descriptionImage.setImage(UIImage(systemName: "pencil"), for: .normal)
        descriptionImage.tintColor = .systemBlue
        
        view.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 20).isActive = true
        descriptionLabel.leftAnchor.constraint(equalTo: descriptionImage.rightAnchor, constant: 20).isActive = true
        descriptionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 20).isActive = true
        descriptionLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        descriptionLabel.text = "詳細說明"
        
        view.addSubview(descriptionTextView)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20).isActive = true
        descriptionTextView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        descriptionTextView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        descriptionTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        if isItemExist == true {
            descriptionTextView.text = itemData?.itemDescription
        }
    }
}
