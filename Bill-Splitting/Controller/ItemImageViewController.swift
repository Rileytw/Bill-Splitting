//
//  ItemImageViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/15.
//

import UIKit

class ItemImageViewController: UIViewController {

    let width = UIScreen.main.bounds.size.width
    let height = UIScreen.main.bounds.size.height
    var photoView = UIView()
    var photoImage = UIImageView()
    let dismissButton = UIButton()
    var image: String?
    
    private let size = 200
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.9)
        addImageView(image: image ?? "")
        setDismissButton()
    }

    func addImageView(image: String) {
        view.addSubview(photoImage)
        photoImage.getImage(image)
        photoImage.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        photoImage.center = view.center
        photoImage.contentMode = .scaleAspectFit
    }
    
    func setDismissButton() {
        view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        dismissButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.tintColor = .greenWhite
        
        dismissButton.addTarget(self, action: #selector(dismissPhotoView), for: .touchUpInside)
    }
    
    @objc func dismissPhotoView() {
        self.dismiss(animated: true, completion: nil)
    }
}
