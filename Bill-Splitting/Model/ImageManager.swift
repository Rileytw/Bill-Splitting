//
//  ImageManager.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/20.
//

import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseStorage

class ImageManager {
    static var shared = ImageManager()
    
    func uploadImageToStorage(image: UIImage, completion: @escaping (String) -> Void) {
        let storageRef = Storage.storage().reference().child("UserImages").child("\(userId).png")
        
        if let uploadData = image.pngData() {
            storageRef.putData(uploadData, metadata: nil) { (data, error) in
                if error != nil {
                    print("Error: \(error!.localizedDescription)")
                    return
                }
                
                storageRef.downloadURL { (url, error) in
                    if let url = url {
                        print("url \(url)")
                        completion(url.absoluteString)
                    }
                }
            }
        }
    }
    
}
