//
//  ScanQRCodeViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/27.
//

import UIKit
import AVFoundation

class ScanQRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession = AVCaptureSession()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var qrCodeFrameView: UIView?
    var qrCodeContent: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scanQRCode()
        setQRCodeFrameView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    func scanQRCode() {
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get the camera device")
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
            return
        }

    }
    
    func setQRCodeFrameView() {
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 1
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }

        let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
        guard let metadataObj = metadataObj else { return }

        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            if let barCodeObject = previewLayer.transformedMetadataObject(for: metadataObj) {
                qrCodeFrameView?.frame = barCodeObject.bounds
            }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

            if metadataObj.stringValue != nil {
                qrCodeContent = metadataObj.stringValue
                print("\(qrCodeContent)")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
