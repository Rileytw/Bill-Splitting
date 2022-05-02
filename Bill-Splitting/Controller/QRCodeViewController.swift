//
//  QRCodeViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/27.
//

import UIKit
import CoreImage

class QRCodeViewController: UIViewController {

    var qrCodeView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        setQRCodeView()
        
    }
    
    func generateQRCode(qrString: String) -> UIImage {
            let stringData = qrString.data(using: String.Encoding.utf8)
            
            let qrFilter = CIFilter(name: "CIQRCodeGenerator")
            qrFilter?.setValue(stringData, forKey: "inputMessage")
            qrFilter?.setValue("H", forKey: "inputCorrectionLevel")
            let qrCIImage = qrFilter?.outputImage
            guard let qrCIImage = qrCIImage else { return UIImage() }

            let codeImage = UIImage(ciImage: qrCIImage)
            return codeImage
    }
    
    func setQRCodeView() {
        view.addSubview(qrCodeView)
        qrCodeView.translatesAutoresizingMaskIntoConstraints = false
        qrCodeView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        qrCodeView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        qrCodeView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        qrCodeView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        qrCodeView.image = generateQRCode(qrString: AccountManager.shared.currentUser.currentUserEmail)
    }

}
