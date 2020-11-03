//
//  HomeMoneyPopView.swift
//  TianXin
//
//  Created by SDS on 2020/10/29.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class HomeMoneyPopView: SDSBaseCoverPopView {
    override func setsubBGView() -> UIView {
        let view = UIView.xib(xibName: "HomeChongzhiView") as! HomeChongzhiView
        view.sdsSize = CGSize(width: 270, height: 470)
        return view
    }

}
