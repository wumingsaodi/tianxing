//
//  UIImageView+add.swift
//  TianXin
//
//  Created by SDS on 2020/9/17.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import Kingfisher
protocol sdsImageSourceType {
}
extension String:sdsImageSourceType{}
extension UIImage:sdsImageSourceType{}
extension Optional:sdsImageSourceType{}
extension UIImageView{
    func loadUrl<T:sdsImageSourceType>(urlStr:String,placeholder:T,size:CGSize? = nil) {
         
        loadUrl(urlStr: urlStr, placeholder: placeholder, size:size, progressBlock: nil, finshBlock: nil)
    }
    func loadUrl<T:sdsImageSourceType>(urlStr:String,placeholder:T?,size:CGSize?, progressBlock:((_ curret:Int64,_ total:Int64)->Void)?,finshBlock:(()->Void)?){
        guard let url = URL(string: urlStr) else {
                if placeholder != nil {
                    let ploderImg = T.self == UIImage.self ? placeholder as? UIImage : UIImage(named: placeholder as? String ?? "")
                    self.image = ploderImg
                }
            
            return
        }
        
        let ploderImg = T.self == UIImage.self ? placeholder as? UIImage : UIImage(named: placeholder as? String ?? "")
//        RetrieveImageResult
        if let size = size {
            let imgSize = CGSize(width: size.width * UIScreen.main.scale, height: size.height * UIScreen.main.scale)
            self.kf.setImage(with: url, placeholder: ploderImg, options: [KingfisherOptionsInfoItem.processor(DownsamplingImageProcessor.init(size: imgSize))])
            return
        }
       

        self.kf.setImage(with: ImageResource.init(downloadURL:url), placeholder: ploderImg, options: nil, progressBlock: { (cur, total) in
            if progressBlock != nil {
                progressBlock!(cur,total)
            }
        }) { (res) in
            if finshBlock != nil {
                 finshBlock!()
            }
           
        }
    }
}
