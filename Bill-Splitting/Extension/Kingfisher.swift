//
//  Kingfisher.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/23.
//

import UIKit
import Kingfisher

extension UIImageView {

    func getImage(_ urlString: String?, placeHolder: UIImage? = nil) {

        guard let urlString = urlString else { return }
        
        let url = URL(string: urlString)

        self.kf.setImage(with: url, placeholder: placeHolder)
    }
}
