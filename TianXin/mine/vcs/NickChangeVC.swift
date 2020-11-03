//
//  NickChangeVC.swift
//  TianXin
//
//  Created by SDS on 2020/9/29.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class NickChangeVC: SDSBaseVC {
//    var nickNameSureBlock:((String)->Void)?
    lazy  var vm:UserInfoViewModel = {
        return UserInfoViewModel()
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "修改昵称"
        setNav()
        setUI()
        LocalUserInfo.share.getLoginInfo {[weak self] (model) in
            if let model = model{
                self?.nameF.text = model.nickName
            }
        }
    }
    func setNav(){
        let rightBut = UIButton.createButWith(title: "确定", titleColor: .Hex("#FF87827D"), font: .pingfangSC(18)) {[weak self] (but) in
                if self?.nameF.text?.count ?? 0 > 0 {
                    self?.vm.uploadUserInfo(nickName: self?.nameF.text ?? "", success: { (_) in
                        SDSHUD.showSuccess("昵称修改成功")
                        self?.navigationController?.popViewController(animated: true)
                    })
                }
        }
        rightBut.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBut)
    }
    func setUI(){
        let lab = UILabel.createLabWith(title: "昵称", titleColor: .Hex("#FF3B372B"), font: .pingfangSC(17))
        self.view.addSubview(lab)
        //
        self.view.addSubview(nameF)
        let text = "昵称规则：\n1.昵称不支持数字、字母以及特殊字符\n2.昵称仅支持修改一次"
        let remindL = UILabel.createLabWith(title: text, titleColor: .Hex("#FF87827D"), font: .pingfangSC(15))
        remindL.numberOfLines = 0
        self.view.addSubview(remindL)
        //
        lab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(KnavHeight)
            make.height.equalTo(47)
        }
        nameF.snp.makeConstraints { (make) in
            make.top.equalTo(lab.snp.bottom)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: KScreenW, height: 44))
        }
        remindL.snp.makeConstraints { (make) in
            make.top.equalTo(nameF.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(20)
        }
    }
    
    
    lazy var nameF:TXTextField = {
        let tf = TXTextField()
        tf.backgroundColor = .white
        tf.placeholder = "请输入昵称"
        tf.textInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tf.text = ""
        tf.textColor = .Hex("#FF3B372B")
        tf.textAlignment = .left
        tf.addTarget(self, action: #selector(nickTextFieldDidChange(tf:)), for: .editingChanged)
        let lab = UILabel.createLabWith(title: "\(tf.text?.count ?? 0)/10", titleColor: .Hex("#FF87827D"), font: .pingfangSC(12))
        lab.tag = 102
        tf.addSubview(lab)
        lab.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
        }
    return tf
    }()
    
    @objc func nickTextFieldDidChange(tf:UITextField){
        if tf.text?.count ?? 0 > 10 {
            tf.text = tf.text![0,10]
        }
        let lab = tf.viewWithTag(102) as! UILabel
        lab.text = "\(tf.text!.count)/10"
    }
}

