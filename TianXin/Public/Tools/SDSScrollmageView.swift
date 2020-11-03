//
//  SDSScrollmageView.swift
//  TianXin
//
//  Created by SDS on 2020/9/26.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class SDSScrollmageView: UIView {
    lazy var scrollv:UIScrollView = {
        let scroll = UIScrollView()
        return scroll
    }()
    var perX:CGFloat = .zero
    var perY:CGFloat = .zero
    init(imgName:String) {
        super.init(frame: .zero)
        self.addSubview(scrollv)
        let imgv = UIImageView.init(image: UIImage(named: imgName))
        imgv.frame = CGRect(x: 0, y: 0, width: Configs.Dimensions.screenWidth*2, height: KScreenH*2)
        scrollv.addSubview(imgv)
        scrollv.contentSize = imgv.sdsSize
        perX = Configs.Dimensions.screenWidth / 10 / 60
        perY = KScreenH / 10 / 60
       let displayer =  CADisplayLink(target: self, selector: #selector(scrollMove))
        displayer.add(to: RunLoop.current, forMode: .common)
        self.addSubview(scrollv)
        scrollv.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        let cover = UIView()
        cover.backgroundColor = .init(white: 0, alpha: 0.1)
        self.addSubview(cover)
        cover.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func scrollMove(){
        let offsetX = scrollv.contentOffset.x
//        let  ofsetY = scrollv.contentOffset.y
        if offsetX < 0 || offsetX > Configs.Dimensions.screenWidth {
            perX = -perX
            perY = -perY
        }
        
        scrollv.contentOffset = CGPoint(x: scrollv.contentOffset.x  + perX , y: scrollv.contentOffset.y  + perY)
        
    }
}
