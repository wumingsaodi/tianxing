//
//  1221232.swift
//  TianXin
//
//  Created by SDS on 2020/10/16.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class HomeCollectionCellHeader: UICollectionReusableView {
  lazy  var imgV:UIImageView = {
    let imgv = UIImageView()
    imgv.image = UIImage(named: "icon_button_xuanzhong")
    return imgv
    }()
    lazy var titleL:UILabel = {
        let lab = UILabel.createLabWith(title: "最新更新", titleColor: .Hex("#FF3B372B"), font:.pingfangSC(24))
        return lab
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(imgV)
        self.addSubview(titleL)
              titleL.snp.makeConstraints { (make) in
                  make.left.equalToSuperview().offset(12)
                  make.centerY.equalToSuperview()
              }
        
        imgV.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(-10)
            
            make.centerY.equalTo(titleL.snp.bottom)
        }
      
//        let moreBut = UIButton.createButWith(title: "更多", titleColor: .Hex("#FF87827D"), font: .pingfangSC(13), image: UIImage(named: "Back_more")) { (_) in
//            
//        }
//        moreBut.setButType(type: .imgRight, padding: 5)
//        self.addSubview(moreBut)
//        moreBut.snp.makeConstraints { (make) in
//            make.centerY.equalToSuperview()
//            make.right.equalToSuperview().offset(-10)
//        }
    }
    func setHeadText(text:String) {
        titleL.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
