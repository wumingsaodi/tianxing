//
//  UIImage+add.swift
//  TianXin
//
//  Created by SDS on 2020/9/18.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
enum GradienType:Int {
    case horizontal = 0;
    case vertical = 1
    case axis = 2
}
extension UIImage{
    /**
     获取渐变图片
     */
    static func CreateGradienImg(colors:[UIColor],type:GradienType = .horizontal,size:CGSize = CGSize(width: 1, height: 1))->UIImage{
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        let context = UIGraphicsGetCurrentContext()!
            let colorSpace = CGColorSpaceCreateDeviceRGB()
        let cgcolors = colors.map { (color) -> CGColor in
            color.cgColor
        }
        let gradient = CGGradient(colorsSpace: colorSpace, colors: cgcolors as CFArray, locations: nil)
            // 第二个参数是起始位置，第三个参数是终止位置
        context.drawLinearGradient(gradient!, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 1, y: 0), options: CGGradientDrawingOptions(rawValue: 0))
           let img =  UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        return img!
    }
    /**
     通过颜色获取图片
     */
    static func createImgWithColor(color:UIColor,size:CGSize = CGSize(width: 1, height: 1)) ->UIImage{
        UIGraphicsBeginImageContext(size)
      let context =    UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        context?.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
