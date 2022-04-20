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
    var completeButton = UIButton()
    let imagePickerController = UIImagePickerController()
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAddPhotoButton()
        setPhotoImageView()
        setCompleteButton()
        imagePickerController.delegate = self
        
    }
    
    func setAddPhotoButton() {
        view.addSubview(addPhotoButton)
        addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        addPhotoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
        addPhotoButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        addPhotoButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        addPhotoButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        addPhotoButton.setTitle("Upload Photo", for: .normal)
        addPhotoButton.backgroundColor = .systemGray
        addPhotoButton.addTarget(self, action: #selector(pressUploadPhoto), for: .touchUpInside)
    }
    
    @objc func pressUploadPhoto() {
        let imagePickerAlertController = UIAlertController(title: "上傳照片", message: "拍攝或上傳照片", preferredStyle: .actionSheet)
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
        photoImageView.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: 40).isActive = true
        photoImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        photoImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        photoImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        //        photoImageView.image = UIImage(systemName: "person.3")
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
        guard let selectedImage = selectedImage else { return }

        ImageManager.shared.uploadImageToStorage(image: selectedImage) { urlString in
            print("======\(urlString)")
        }
        
    }
}
