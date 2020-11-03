//
//  MoreTopView.swift
//  TianXin
//
//  Created by SDS on 2020/9/22.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class MoreTopView: UIView {

    init(images: [UIImage],clickBlock:@escaping(Int,UIButton)->Void) {
        super.init(frame: .zero)
        self.backgroundColor = .white
        let beignX:CGFloat = 15
        let wh:CGFloat =  76
        var x:CGFloat = beignX
        var y:CGFloat = 10
        let margin:CGFloat = (Configs.Dimensions.screenWidth - 30 - 4*wh)/3
        for i in 0..<images.count {
            let  but  = UIButton.createButWith( backGroudImg: images[i]) { (but) in
                clickBlock(i,but)
            }
            but.cornor(conorType: .allCorners, reduis: 5)
            self.addSubview(but)
            but.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: wh, height: wh))
                make.left.equalToSuperview().offset(x)
                make.top.equalToSuperview().offset(y)
                if i == images.count - 1 {
                    make.bottom.equalToSuperview().offset(-15)
                }
            }
            x += margin + wh
            if x > Configs.Dimensions.screenWidth - beignX - wh {
               x = beignX
                y += wh + margin
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
