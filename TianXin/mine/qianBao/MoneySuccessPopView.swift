//
//  MoneySuccessPopView.swift
//  TianXin
//
//  Created by SDS on 2020/10/29.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class MoneySuccessPopView: SDSBaseCoverPopView {

    override func setsubBGView() -> UIView {
        let bgv = UIView()
        bgv.sdsSize = CGSize(width: 300, height: 361.5)
        bgv.backgroundColor = .white
        let imgv = UIImageView.init(image: #imageLiteral(resourceName: "img_chongzhi"))
        bgv.addSubview(imgv)
        //
        let titleL = UILabel.createLabWith(title: "充值成功", titleColor: .Hex("#FFFAA454"), font: .pingfangSC(23))
        bgv.addSubview(titleL)
        //
        let mesageL = UILabel.createLabWith(title: "充值完成后，根据系统消息提示查收充值金额，祝您玩的愉快", titleColor: .Hex("#FF484848"), font: .pingfangSC(16))
        mesageL.numberOfLines = 0
        bgv.addSubview(mesageL)
        //
        let sureBut = UIButton.createButWith(title: "确定", titleColor: .white, backGroudImg: mainYellowGradienImg) {[weak self] (but) in
            self?.cancel()
            kAppdelegate.getNavvc()?.popViewController(animated: true)
        }
        sureBut.cornor(conorType: .allCorners, reduis: 19)
        bgv.addSubview(sureBut)
        //
        let cancel = UIButton.createButWith(title: "取消", titleColor: mainYellowColor) {[weak self] (but) in
            kAppdelegate.getNavvc()?.popViewController(animated: true)
            self?.cancel()
        }
        
        cancel.cornor(conorType: .allCorners, reduis: 19, borderWith: 1, borderColor: mainYellowColor)
        bgv.addSubview(cancel)
        //
        imgv.snp.makeConstraints { (make) in
            make.height.equalTo(107.5)
            make.top.left.right.equalToSuperview()
        }
        //
        titleL.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(imgv.snp.bottom).offset(-5)
        }
        //
        mesageL.snp.makeConstraints { (make) in
            make.width.equalTo(240)
            make.top.equalTo(titleL.snp.bottom).offset(13)
            make.centerX.equalToSuperview()
        }
        //
        sureBut.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 205, height: 38))
            make.centerX.equalToSuperview()
            make.top.equalTo(mesageL.snp.bottom).offset(35)
        }
        //
        cancel.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 205, height: 38))
            make.centerX.equalToSuperview()
            make.top.equalTo(sureBut.snp.bottom).offset(18)
        }
        return bgv
    }

}
