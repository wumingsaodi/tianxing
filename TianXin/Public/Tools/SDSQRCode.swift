//
//  SDSQRCode.swift
//  TianXin
//
//  Created by SDS on 2020/10/2.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class SDSQRCode: NSObject {
    static func createQRCode(qrStr:String,qrimgBame:String? = nil,downTitle:String? = nil ,size:CGSize = CGSize(width: 87, height: 87))->UIImage{
        let data = qrStr.data(using: .utf8, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")!
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        let qrcCIImg = filter.outputImage
         let colorFilter = CIFilter(name: "CIFalseColor")!
        colorFilter.setDefaults()
       colorFilter.setValue(qrcCIImg, forKey: "inputImage")
        colorFilter.setValue(CIColor(red: 0, green: 0, blue: 0), forKey: "inputColor0")
        colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor1")
        let codeImage = UIImage(ciImage: colorFilter.outputImage!
            .transformed(by: CGAffineTransform(scaleX: size.width / 31, y: size.height / 31)))
        //内嵌logo
        if qrimgBame != nil  || downTitle != nil {
            let height = downTitle == nil ? codeImage.size.height : codeImage.size.height + 20
                   let rect = CGRect(x: 0, y: 0, width: codeImage.size.width, height: height)
                 UIGraphicsBeginImageContext(rect.size)
            
                 codeImage.draw(in: CGRect(x: 0, y: 0, width: codeImage.size.width, height:  codeImage.size.height))
            
            if qrimgBame != nil  {
                 let iconImage = UIImage(named: qrimgBame!)
                let avatarSize = CGSize(width: rect.size.width / 4, height: rect.size.height / 4)
                let x = (rect.width - avatarSize.width) / 2
                let y = (rect.height - avatarSize.height) / 2
                
                iconImage!.draw(in: CGRect(x: x, y: y, width: avatarSize.width, height: avatarSize.height))
               
            }
            if let title = downTitle {
                let attr = [NSAttributedString.Key.foregroundColor: UIColor.black,NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]
                
                (title as NSString).draw(at: CGPoint(x: 0, y: height - 18), withAttributes: attr)
            }
        
            let resultImage = UIGraphicsGetImageFromCurrentImageContext()

            UIGraphicsEndImageContext()
                           return resultImage!
        }
        return codeImage
    }
}
