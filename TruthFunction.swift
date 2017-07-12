//
//  TruthFunction.swift
//  Material
//
//  Created by Truth on 2016. 1. 4..
//  Copyright © 2016년 Truth. All rights reserved.
//

import UIKit

func stringToColor(_ hex: String) -> UIColor {
    var rgbValue: UInt32 = 0
    
    
    var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    cString.remove(at: cString.startIndex)
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColorFromRGB(rgbValue)
}

func UIColorFromRGB(_ rgbValue: UInt32) -> UIColor{
    let color = UIColor(
        red:(CGFloat((rgbValue & 0xFF0000) >> 16))/255.0,
        green:(CGFloat((rgbValue & 0xFF00) >> 8))/255.0,
        blue:(CGFloat(rgbValue & 0xFF))/255.0,
        alpha:1.0
    )
    return color
}

func hexStringFromColor(_ color: UIColor) -> String {
    let components = color.cgColor.components
    let r = Float((components?[0])!)
    let g = Float((components?[1])!)
    let b = Float((components?[2])!)
    return String(format: "R%02lD G%02lD B%02lD", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255.0))
}
