//
//  PassWordChangeVC.swift
//  TianXin
//
//  Created by SDS on 2020/9/28.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class PassWordChangeVC: SDSBaseVC {
    var selectedBut:UIButton?
    var emailBut:UIButton!
    var userinfo:UserInfoModel = UserInfoModel()
    var isPhotoSelected = true {
        didSet{
            if isPhotoSelected {
                textF.text = LocalUserInfo.share.showPhoto
            }else{
                textF.text = LocalUserInfo.share.showEmail
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
           title = "修改密码"
        setUI()

            nameF.text = LocalUserInfo.share.sdsUserName
            nameF.isEnabled = false
        LocalUserInfo.share.getLoginInfo {[weak self] (info) in
            if let info = info{
                self?.userinfo = info
            }
        }
        if isPhotoSelected {
            textF.text = LocalUserInfo.share.showPhoto
        }else{
            textF.text = LocalUserInfo.share.showEmail
        }
        self.textFdidChange()
    }
    func setUI() {
        let bgv = UIView()
        bgv.backgroundColor = .white
        //
        self.view.addSubview(bgv)
        bgv.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(KnavHeight + 10)
            make.height.equalTo(298.5)
        }
       //
    let photoBut = createTitleBut(title: "手机验证")
        self.selectedBut = photoBut
        let line = photoBut.viewWithTag(103)
        line?.isHidden = false
        bgv.addSubview(photoBut)
        photoBut.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(98)
            make.top.equalToSuperview().offset(21)
        }
        let emailBut = createTitleBut(title: "邮箱验证")
        bgv.addSubview(emailBut)
        emailBut.snp.makeConstraints { (make) in
            make.top.equalTo(photoBut)
            make.right.equalToSuperview().offset(-98)
        }
        
        let nameV = createPassView()
        bgv.addSubview(nameV)
        nameV.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(105)
            make.top.equalTo(photoBut.snp.bottom)
        }
        let photoV = createPassView(isDown: true)
        bgv.addSubview(photoV)
        photoV.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(nameV.snp.bottom)
            make.height.equalTo(nameV)
        }
        //
        self.view.addSubview(sureBut)
        sureBut.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(bgv.snp.bottom).offset(50)
            make.size.equalTo(CGSize(width: 205, height: 38))
        }
    }
    func createTitleBut(title:String)->UIButton {
        let but = UIButton.createButWith(title: title, titleColor: .Hex("#FF3B372B"), font: .pingfangSC(17)) { [weak self](but) in
            if self!.selectedBut == but {
                return
            }
            
            let line = but.viewWithTag(103)
            line?.isHidden = false
            if self!.selectedBut != nil {
                let selectedline = self!.selectedBut!.viewWithTag(103)
                selectedline?.isHidden = true
            }
            if but.currentTitle == "手机验证"{
                self?.isPhotoSelected = true
                self!.textL.text = "手机号"
//                self!.textF.text = nil
                 self?.textFdidChange()
                self!.textF.placeholder = "请输入绑定手机号"
            } else if but.currentTitle == "邮箱验证" {
                self!.isPhotoSelected = false
                self!.textL.text = "邮箱号"
//                self!.textF.text = nil
                self?.textFdidChange()
                self!.textF.placeholder = "请输入绑定邮箱"
            }
            self!.selectedBut = but
        }
        let line = UIView()
        line.tag = 103
        line .isHidden = true
        line.backgroundColor = mainYellowColor
        but.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-1)
            make.size.equalTo(CGSize(width: 20, height: 2))
        }
        return but
    }
    func createPassView(isDown:Bool = false ) -> UIView {
        let bgv = UIView()
        bgv.backgroundColor = .white
         let lab = UILabel.createLabWith(title: "用户名", titleColor: .Hex("#FF3B372B"), font: .pingfangSC(17))
        bgv.addSubview(lab)
        lab.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(25)
            make.left.equalToSuperview().offset(20)
        }
        let tf  = UITextField()
        tf.font = .pingfangSC(15)
        tf.textAlignment = .left
        tf.addTarget(self, action: #selector(textFdidChange), for: .editingChanged)
        bgv.addSubview(tf)
        tf.snp.makeConstraints { (make) in
            make.top.equalTo(lab.snp.bottom).offset(9)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-10)
        }
        let line = UIView()
        bgv.addSubview(line)
        line.backgroundColor = baseVCBackGroudColor_grayWhite
        line.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        if isDown {
            lab.text = "手机号"
            textL = lab
            //
            self.textF = tf
            tf.placeholder = "请输入手机号"
        }else{
            //
            tf.placeholder = "请输入用户名"
            self.nameF = tf

        }
        return bgv
    }
    var textL:UILabel!
    var nameF:UITextField!
    var textF:UITextField!
 
    lazy var sureBut:UIButton = {
        let backImg = UIImage.createImgWithColor(color: .Hex("#B3E1E1E1"))
        let selectedImg = UIImage.CreateGradienImg(colors: [.Hex("#FFFFD26B"),.Hex("#FFF8944B")])
        let but = UIButton.createButWith(title: "下一步", titleColor: .Hex("#FFD3D3D3"), font: .pingfangSC(15), backGroudImg: backImg) { [weak self](but) in
           
            var text = ""
            if self!.isPhotoSelected {
                text  = self?.textF.text == LocalUserInfo.share.showPhoto ? self!.userinfo.phone : self?.textF.text ?? ""
            }else {
                text  = self?.textF.text == LocalUserInfo.share.showEmail ? self!.userinfo.email : self?.textF.text ?? ""
            }
            if !self!.isPhotoOrEmailTrueFormat(text: text){
                if self!.isPhotoSelected {
                    SDSHUD.showError("手机号格式错误")
                }else{
                    SDSHUD.showError("邮箱格式错误")
                }
                return
            }
            let vc = CheckingVC.init(text: text, isPhoto: self!.isPhotoSelected)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        but.cornor(conorType: .allCorners, reduis: 19)
        but.isEnabled = false
        but.setBackgroundImage(selectedImg, for: .selected)
        but.setTitleColor(.white, for: .selected)
        return but
    }()
    
    func isPhotoOrEmailTrueFormat(text:String) -> Bool {
        if self.isPhotoSelected {
            if  text.count != 11 {
               return false
            }
//            if   Int text.count < {
//                return false
//            }
        }else{
            if text.firstIndex(of: "@") == nil || !(text.hasSuffix(".com") || text.hasSuffix(".cn")) {
                return false
            }
        }
        return true
    }
    
    @objc func textFdidChange(){
        if nameF.text?.count ?? 0 > 0 && textF.text?.count ?? 0 > 0{
            sureBut.isSelected = true
            sureBut.isEnabled = true
        }else {
            sureBut.isSelected = false
            sureBut.isEnabled = false
        }
    }
}
