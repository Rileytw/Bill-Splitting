//
//  UIColor+Extension.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/24.
//

import UIKit

extension UIColor {
    
    static func hexStringToUIColor(hex: String) -> UIColor {

        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if (cString.count) != 6 {
            return UIColor.gray
        }

        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static let greenWhite = UIColor.hexStringToUIColor(hex: "FAFDF6")
//    ECEBF3
//    FAFDF6
//    BCD4DE
//    "EFFFFB" (old)
    
    static let darkBlueColor = UIColor.hexStringToUIColor(hex: "031927")
    
    static let styleGreen = UIColor.hexStringToUIColor(hex: "16BAC5")
//    A5CCD1
//    05DFD7(old)
//    25A18E
//    9FFFCB
//    9FFFF5
//    6ABEA7
//    16BAC5
    
    static let styleRed = UIColor.hexStringToUIColor(hex: "C83E4D")
//FD5D5D(old)
//    FF6363
//    C83E4D
    static let selectedColor = UIColor.hexStringToUIColor(hex: "5EB1BF")
    // 3E5C76
    // 5EB1BF
    // 508AA8
    // 6BA8A9
    
    static let styleOrange = UIColor.hexStringToUIColor(hex: "F4B860")
//    F4B860
//    FFAD60(old)
    
    static let styleBlue = UIColor.hexStringToUIColor(hex: "041C32")
    
    static let styleYellow = UIColor.hexStringToUIColor(hex: "FFCE45")
    
    static let styleLightBlue = UIColor.hexStringToUIColor(hex: "61A4BC")
}
