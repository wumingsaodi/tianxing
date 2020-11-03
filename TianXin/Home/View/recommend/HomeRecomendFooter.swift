//
//  HomeRecomendFooter.swift
//  TianXin
//
//  Created by SDS on 2020/10/14.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class HomeRecomendFooter: UICollectionReusableView {
    var refreshBlock:(()->Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        let but = UIButton.createButWith(title: "换一批", titleColor: .Hex("#3B372B"), font: .pingfangSC(16), image: #imageLiteral(resourceName: "icon_shuaxin")) {[weak self] (_) in
            if self?.refreshBlock != nil {
                self?.refreshBlock!()
            }
        }
        self.addSubview(but)
        but.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
