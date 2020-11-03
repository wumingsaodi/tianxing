//
//  UIColoer+add.swift
//  TianXin
//
//  Created by SDS on 2020/9/19.
//  Copyright © 2020 SDS. All rights reserved.
//1

import UIKit
func hexToNum(hexStr:String)->Int{
    var sum:Int = 0
    
    let str = hexStr.uppercased()
    for i in str.utf8 {
        sum = sum * 16 + Int(i) - 48
        if i >= 65 {
            sum -= 7
        }
    }
     return sum
}
func hexFloat(_ hexStr:String)->CGFloat{
    return CGFloat(hexToNum(hexStr: hexStr))/255.0
}
extension UIColor{
    /**
       16进制颜色转10进制颜色
     */
    class func Hex(_ hexStr:String)->UIColor{
        var hex:String = hexStr
        if hexStr.hasPrefix("#"){
            hex = hexStr[1]
        }
        if hex.count == 8 {
            return UIColor.init(red:hexFloat(hex[2,2]), green: hexFloat(hex[4,2]), blue: hexFloat(hex[6,2]), alpha: hexFloat(hex[0,2]))
        }else if hex.count == 6 {
            return UIColor.init(red:hexFloat(hex[0,2]), green: hexFloat(hex[2,2]), blue: hexFloat(hex[4,2]), alpha: 1)
        }
        return .clear
    }
  
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(red: CGFloat(((hex >> 16) & 0xff)) / 255.0, green: CGFloat(((hex >> 8) & 0xff)) / 255.0, blue: CGFloat((hex & 0xff)) / 255.0, alpha: alpha)
    }
}

extension UIImage {
    convenience init?(color: UIColor) throws {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { throw NSError() }
        self.init(cgImage: cgImage)
    }
}

