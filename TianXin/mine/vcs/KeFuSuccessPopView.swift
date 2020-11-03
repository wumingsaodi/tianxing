//
//  KeFuSuccessPopView.swift
//  TianXin
//
//  Created by SDS on 2020/10/29.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class KeFuSuccessPopView: SDSBaseCoverPopView {

    override func setsubBGView() -> UIView {
      let bgv = UIView()
        bgv.backgroundColor = .white
        bgv.sdsSize = CGSize(width: 279.5, height: 208)
        bgv.cornor(conorType: .allCorners, reduis: 8)
        //
        let but = UIButton.createButWith(title: "提交成功", titleColor: .white, font: .pingfangSC(18), image: #imageLiteral(resourceName: "icon_success"), backGroudImg: mainYellowGradienImg)
        but.butPadding = 5
//        but.isEnabled = false
        but.isUserInteractionEnabled = false
        bgv.addSubview(but)
        //
        let lab = UILabel.createLabWith(title: "感谢您对甜杏视频的信任与支持，我们将尽快为您解决！", titleColor: .Hex("#FF87827D"), font: .pingfangSC(16), aligment:.center)
        lab.numberOfLines = 0
        bgv.addSubview(lab)
        //
        let surebut = UIButton.createButWith(title: "确认", titleColor: .white, font: .pingfangSC(15), backGroudImg: mainYellowGradienImg) { [weak self](but) in
            self?.cancel()
            kAppdelegate.getNavvc()?.popViewController(animated: true)
        }
        surebut.cornor(conorType: .allCorners, reduis: 20)
        bgv.addSubview(surebut)
        but.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(61)
        }
        //
        lab.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(but.snp.bottom).offset(23)
            make.width.equalTo(225)
        }
        //
        surebut.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(lab.snp.bottom).offset(18)
            make.size.equalTo(CGSize(width: 200, height: 40))
        }

        return bgv
    }

}
