//
//  ScanQRCodeViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/27.
//

import UIKit
import AVFoundation

class ScanQRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    // MARK: - Property
    var captureSession = AVCaptureSession()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var qrCodeFrameView = UIView()
    typealias QRCodeData = (String) -> Void
    var qrCodeContent: QRCodeData?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        scanQRCode()
        setDismissButton()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        previewLayer.cornerRadius = 10
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    // MARK: - Method
    func scanQRCode() {
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            return
        }
        
        do {
            
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            previewLayer.frame = view.layer.bounds
            view.layer.addSublayer(previewLayer)
            captureSession.startRunning()
            
        } catch {
            print(error)
            ProgressHUD.shared.view = view
            ProgressHUD.showFailure(text: ErrorType.generalError.errorMessage)
            return
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            qrCodeFrameView.frame = .zero
            return
        }
        
        let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
        guard let metadataObj = metadataObj else { return }
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            if let barCodeObject = previewLayer.transformedMetadataObject(for: metadataObj) {
                qrCodeFrameView.frame = barCodeObject.bounds
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 4
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            if metadataObj.stringValue != nil {
                qrCodeContent?(metadataObj.stringValue ?? "")
                self.dismiss(animated: true, completion: nil)
            }
        }
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
