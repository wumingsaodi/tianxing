//
//  selectedPhotoOrEmail.swift
//  TianXin
//
//  Created by SDS on 2020/9/28.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class selectedPhotoOrEmail: SDSBaseVC {
    var type:YanZhengType = .photo
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "绑定手机号"
        if type == .email {
            title = "绑定邮箱"
            photoL.text = "邮箱"
            photoDetailL.text = "135****09@qq.com"
            genghuanL.text = "如需要更换邮箱，请再次"
            genghuanBut.setTitle("绑定邮箱", for: .normal)
        }
        setUI()
    }
    func  setUI(){
        let bgv = UIView()
        self.view.addSubview(bgv)
        bgv.backgroundColor = .white
        bgv.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(44)
        }
        bgv.addSubview(photoL)
        photoL.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15)
        }
        bgv.addSubview(photoDetailL)
        photoDetailL.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        //
        let bgv2 = UIView()
        self.view.addSubview(bgv2)
        bgv2.snp.makeConstraints { (make) in
            make.top.equalTo(bgv.snp.bottom).offset(38)
            make.centerX.equalToSuperview()
        }
        bgv2.addSubview(genghuanL)
        genghuanL.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        bgv2.addSubview(genghuanBut)
        genghuanBut.snp.makeConstraints { (make) in
            make.left.equalTo(genghuanL.snp.right)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    lazy var photoL:UILabel = {
        let lab = UILabel.createLabWith(title: "手机号", titleColor: .Hex("#FF3B372B"), font: .pingfangSC(17))
        return lab
    }()
    lazy var photoDetailL:UILabel = {
        let lab = UILabel.createLabWith(title: "135****0987", titleColor: .Hex("#FF87827D"), font: .pingfangSC(15))
        return lab
    }()
    lazy var genghuanL:UILabel = {
           let lab = UILabel.createLabWith(title: "如需要更换手机号，点击联系", titleColor: .Hex("#FF87827D"), font: .pingfangSC(13))
           return lab
       }()
    lazy var genghuanBut:UIButton = {
        let but = UIButton.createButWith(title: "在线客服", titleColor: .Hex("#FFFBB560"), font: .pingfangSC(13)) {[weak self](but) in
            if (but.currentTitle == "在线客服"){
                let vc = KefuVC()
                self?.navigationController?.pushViewController(vc, animated: true)
            }else{
                
            }
        }
         return but
    }()
   
}
