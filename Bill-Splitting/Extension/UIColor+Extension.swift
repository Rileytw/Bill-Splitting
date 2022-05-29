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
    
    static let darkBlueColor = UIColor.hexStringToUIColor(hex: "031927")
    
    static let styleGreen = UIColor.hexStringToUIColor(hex: "16BAC5")

    static let styleRed = UIColor.hexStringToUIColor(hex: "C83E4D")

    static let selectedColor = UIColor.hexStringToUIColor(hex: "5EB1BF")
    
    static let styleOrange = UIColor.hexStringToUIColor(hex: "F4B860")
    
    static let styleBlue = UIColor.hexStringToUIColor(hex: "041C32")
    
    static let styleYellow = UIColor.hexStringToUIColor(hex: "FFCE45")
    
    static let styleLightBlue = UIColor.hexStringToUIColor(hex: "61A4BC")
    
    static let maskBackgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    
    static let viewDarkBackgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
}
