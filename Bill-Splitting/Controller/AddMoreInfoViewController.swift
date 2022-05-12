//
//  AddMoreInfoViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/20.
//

import UIKit
import Lottie

class AddMoreInfoViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    let currentUserId = AccountManager.shared.currentUser.currentUserId
    var photoImageView = UIImageView()
    var addPhotoButton = UIButton()
    var addPhotoLabel = UILabel()
    var completeButton = UIButton()
    var descriptionLabek = UILabel()
    let dismissButton = UIButton()
    var descriptionTextView = UITextView()
    let imagePickerController = UIImagePickerController()
    var selectedImage: UIImage?
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    private var animationView = AnimationView()
    
//    weak var delegate: MoreInfoDelegate?
    
    var isItemExist: Bool = false
    var itemData: ItemData?
    
    typealias UrlData = (String) -> Void
    var urlData: UrlData?
    
    typealias Description = (String) -> Void
    var itemDescription: Description?
    
    typealias ImageData = (UIImage) -> Void
    var itemImage: ImageData?
    
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
    
    func setAddPhotoButton() {
        view.addSubview(addPhotoButton)
        addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        addPhotoButton.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 40).isActive = true
        addPhotoButton.leftAnchor.constraint(equalTo: addPhotoLabel.rightAnchor, constant: 20).isActive = true
        addPhotoButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        addPhotoButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        addPhotoButton.setImage(UIImage(systemName: "camera"), for: .normal)
        addPhotoButton.setTitle("上傳", for: .normal)
        addPhotoButton.setTitleColor(UIColor.greenWhite, for: .normal)
        addPhotoButton.tintColor = UIColor.greenWhite
        addPhotoButton.addTarget(self, action: #selector(pressUploadPhoto), for: .touchUpInside)
        ElementsStyle.styleSpecificButton(addPhotoButton)
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
        
        // MARK: - code for iPad to avoid crash
        imagePickerAlertController.popoverPresentationController?.sourceView = self.view
        
        let xOrigin = self.view.bounds.width / 2
        
        let popoverRect = CGRect(x: xOrigin, y: 0, width: 1, height: 1)
        
        imagePickerAlertController.popoverPresentationController?.sourceRect = popoverRect
        
        imagePickerAlertController.popoverPresentationController?.permittedArrowDirections = .up
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
        photoImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        
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
    
    @objc func pressComplete() {
        setAnimation()
        itemDescription?(self.descriptionTextView.text)
        if isItemExist == true {
            if selectedImage == nil {
                self.urlData?(itemData?.itemImage ?? "")
                self.dismiss(animated: true, completion: nil)
            } else {
//                getImageURL()
                itemImage?(self.selectedImage ?? UIImage())
                self.dismiss(animated: true, completion: nil)
            }
        } else if selectedImage != nil && isItemExist == false {
//            getImageURL()
            itemImage?(self.selectedImage ?? UIImage())
            self.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func setAnimation() {
        let mask = UIView()
        mask.frame = CGRect(x: 0, y: 0, width: width, height: height)
        mask.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        animationView = .init(name: "upload")
        animationView.frame = CGRect(x: width/2 - 75, y: height/2 - 75, width: 150, height: 150)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        view.addSubview(mask)
        view.addSubview(animationView)
        animationView.play()
    }
    
    
    func setDescription() {
        view.addSubview(descriptionLabek)
        descriptionLabek.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabek.topAnchor.constraint(equalTo: completeButton.bottomAnchor, constant: 20).isActive = true
        descriptionLabek.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        descriptionLabek.widthAnchor.constraint(equalToConstant: 120).isActive = true
        descriptionLabek.heightAnchor.constraint(equalToConstant: 40).isActive = true
        descriptionLabek.text = "詳細說明"
        descriptionLabek.textColor = UIColor.greenWhite
        
        view.addSubview(descriptionTextView)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.topAnchor.constraint(equalTo: descriptionLabek.bottomAnchor, constant: 20).isActive = true
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
        addPhotoLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
    
        addPhotoLabel.textColor = UIColor.greenWhite
        addPhotoLabel.text = "新增照片"
    }
}
