//
//  SearchBar.swift
//  TianXin
//
//  Created by SDS on 2020/9/22.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class SearchBar: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
  lazy  var textF:UITextField = {
    let ft = UITextField()
    ft.font = .pingfangSC(13)
    ft.tintColor = .blue
    ft.placeholder = "请输入你感兴趣的内容"
    return ft
    }()
    
    func setUI() {
        self.sdsSize = CGSize(width: 240, height: 28.5)
        self.layer.cornerRadius =  28.5*0.5

        self.backgroundColor = .Hex("#FFF7F8FC")
        //
        let imgv = UIImageView.init(image: UIImage(named: "seach"))
        self.addSubview(imgv)
        imgv.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15)
        }
        self.addSubview(textF)
        textF.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(imgv.snp.right).offset(3)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
