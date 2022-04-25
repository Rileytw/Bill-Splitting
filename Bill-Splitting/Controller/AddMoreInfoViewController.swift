//
//  AddMoreInfoViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/20.
//

import UIKit
import Lottie

class AddMoreInfoViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var photoImageView = UIImageView()
    var addPhotoButton = UIButton()
    var completeButton = UIButton()
    var descriptionButton = UIButton()
    var descriptionTextView = UITextView()
    let imagePickerController = UIImagePickerController()
    var selectedImage: UIImage?
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    private var animationView = AnimationView()
    
    var isItemExist: Bool = false
    var itemData: ItemData?
    
    typealias UrlData = (String) -> Void
    var urlData: UrlData?
    
    typealias Description = (String) -> Void
    var itemDescription: Description?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setAddPhotoButton()
        setPhotoImageView()
        setDescription()
        setCompleteButton()
        imagePickerController.delegate = self
        
    }
    
    func setAddPhotoButton() {
        view.addSubview(addPhotoButton)
        addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        addPhotoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
        addPhotoButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        addPhotoButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        addPhotoButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        addPhotoButton.setImage(UIImage(systemName: "camera"), for: .normal)
        addPhotoButton.setTitle("上傳照片", for: .normal)
        addPhotoButton.setTitleColor(.systemOrange, for: .normal)
        addPhotoButton.tintColor = .systemOrange
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
        setAnimation()
        itemDescription?(self.descriptionTextView.text)
        if isItemExist == true {
            if selectedImage == nil {
                self.urlData?(itemData?.itemImage ?? "")
                self.dismiss(animated: true, completion: nil)
            } else {
                getImageURL()
            }
        } else if selectedImage != nil && isItemExist == false {
            getImageURL()
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
    
    func getImageURL() {
        guard let selectedImage = selectedImage else { return }
        let fileName = "\(userId)" + "\(Date())"
        ImageManager.shared.uploadImageToStorage(image: selectedImage, fileName: fileName) { [weak self] urlString in
            self?.urlData?(urlString)
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    func setDescription() {
        view.addSubview(descriptionButton)
        descriptionButton.translatesAutoresizingMaskIntoConstraints = false
        descriptionButton.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 20).isActive = true
        descriptionButton.leftAnchor.constraint(equalTo: addPhotoButton.leftAnchor, constant: 0).isActive = true
        descriptionButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        descriptionButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        descriptionButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        descriptionButton.setTitle("詳細說明", for: .normal)
        descriptionButton.tintColor = .systemYellow
        descriptionButton.setTitleColor(.systemYellow, for: .normal)
        
        view.addSubview(descriptionTextView)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.topAnchor.constraint(equalTo: descriptionButton.bottomAnchor, constant: 20).isActive = true
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
