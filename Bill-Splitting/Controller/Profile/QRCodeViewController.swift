//
//  QRCodeViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/27.
//

import UIKit
import CoreImage

class QRCodeViewController: UIViewController {
    
    // MARK: - Property
    var qrCodeView = UIImageView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        setQRCodeView()
        setDismissButton()
    }
    // MARK: - Method
    func generateQRCode(qrString: String) -> UIImage {
        let stringData = qrString.data(using: String.Encoding.utf8)
        
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        qrFilter?.setValue(stringData, forKey: "inputMessage")
        qrFilter?.setValue("M", forKey: "inputCorrectionLevel")
        let qrCIImage = qrFilter?.outputImage
        
        guard let qrCIImage = qrCIImage else { return UIImage() }
        let codeImage = UIImage(ciImage: qrCIImage)
        return codeImage
    }
    
    func setQRCodeView() {
        view.addSubview(qrCodeView)
        qrCodeView.translatesAutoresizingMaskIntoConstraints = false
        qrCodeView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
        qrCodeView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        qrCodeView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        qrCodeView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        qrCodeView.layer.magnificationFilter = CALayerContentsFilter.nearest
        
        qrCodeView.image = generateQRCode(qrString: AccountManager.shared.currentUser.currentUserEmail)
    }
    
    func setDismissButton() {
        let dismissButton = UIButton()
        view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.tintColor = UIColor.greenWhite
        dismissButton.addTarget(self, action: #selector(pressDismiss), for: .touchUpInside)
    }
    
    @objc func pressDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}
