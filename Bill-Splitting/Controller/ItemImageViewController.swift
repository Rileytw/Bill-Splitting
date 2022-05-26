//
//  ItemImageViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/15.
//

import UIKit

class ItemImageViewController: UIViewController, UIScrollViewDelegate {
    
// MARK: - Property
    var scrollImage = UIScrollView()
    var photoView = UIView()
    var photoImage = UIImageView()
    let dismissButton = UIButton()
    var image: String?
    
// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.9)
       
        setScrollView()
        setDismissButton()
    }

// MARK: - Method
    func addImageView(image: String) {
        scrollImage.addSubview(photoImage)
        photoImage.getImage(image)
        photoImage.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        photoImage.center = view.center
        photoImage.contentMode = .scaleAspectFit
        photoImage.isUserInteractionEnabled = true
    }
    
    func setDismissButton() {
        view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        dismissButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.tintColor = .greenWhite
        
        dismissButton.addTarget(self, action: #selector(dismissPhotoView), for: .touchUpInside)
    }
    
    @objc func dismissPhotoView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setScrollView() {
   
        scrollImage.delegate = self
        scrollImage.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        scrollImage.alwaysBounceVertical = false
        scrollImage.alwaysBounceHorizontal = false
        scrollImage.showsVerticalScrollIndicator = true
        scrollImage.flashScrollIndicators()
        
        scrollImage.minimumZoomScale = 1.0
        scrollImage.maximumZoomScale = 6.0
        
        view.addSubview(scrollImage)

        addImageView(image: image ?? "")
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.photoImage
    }
}
