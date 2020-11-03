//
//  HomeOtherVCHeadFirst.swift
//  TianXin
//
//  Created by SDS on 2020/10/14.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import XRCarouselView
class HomeOtherVCHeadFirst: UICollectionReusableView {
    static let headH:CGFloat = 80
    let leftRightMargin:CGFloat = 10
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUI(){
        self.addSubview(itemScrollV)
        itemScrollV.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(5)
            make.height.equalTo(80)
        }
    }
 
    lazy var itemScrollV: HomeDownBannerItemView = {
        let itemscrollv = HomeDownBannerItemView()
        return itemscrollv
    }()
}
