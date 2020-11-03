//
//  LoginVC.swift
//  TianXin
//
//  Created by SDS on 2020/9/25.
//  Copyright © 2020 SDS. All rights reserved.
//
let savePasswordKey = "savePasswordKey"

import UIKit

class LoginVC: SDSBaseVC {
    var nameF:UITextField!
    var passF:UITextField!
    var isNotNeedNav:Bool = false
    lazy var vm:LoginViewModel = {
        return LoginViewModel()
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
      setUI()
        if UserDefaults.standard.bool(forKey: savePasswordKey) {
            self.nameF.text = LocalUserInfo.share.sdsUserName
            self.passF.text = LocalUserInfo.share.sdsPassword
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isNotNeedNav {
             self.setWhiteBackImg()
        }
        
    }
    func setUI()  {
        //
       let scrollbgv = SDSScrollmageView.init(imgName: "background_girl")
        self.view.addSubview(scrollbgv)
        scrollbgv.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        //
        self.view.addSubview(iconv)
       
        iconv.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(90)
        }
        //
        self.view.addSubview(remindL)
        remindL.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconv.snp.bottom).offset(13)
            make.width.equalTo(275)
        }
        //
        let loginV = setLoginView()
        self.view.addSubview(loginV)
        loginV.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(remindL.snp.bottom).offset(24.5)
            make.size.equalTo(CGSize(width: 320, height: 342))
        }
        //
        let visitedBut = UIButton.createButWith(title: "随便逛逛", titleColor: .white, font: .pingfangSC(16)) { (_) in
          
        }
        visitedBut.cornor(conorType: .allCorners, reduis: 18, borderWith: 1, borderColor: mainYellowColor)
        self.view.addSubview(visitedBut)
        visitedBut.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(loginV.snp.bottom).offset(32)
            make.size.equalTo(CGSize(width: 103.5, height: 36))
        }
    }
    func setLoginView() -> UIView {
        let bgv = UIView()
        bgv.backgroundColor = .init(white: 1, alpha: 0.2)
        bgv.cornor(conorType: .allCorners, reduis: 10)
        //
        let loginL = UILabel.createLabWith(title: "登陆", titleColor: .white, font: .pingfangSC(25))
        bgv.addSubview(loginL)
        loginL.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(25)
        }
        //
        let nameV = createInputView(imgName: "icon_user", holderStr: "请输入用户名")
        bgv.addSubview(nameV)
        nameV.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(90)
            make.size.equalTo(nameV.sdsSize)
        }
        let passV = createInputView(imgName: "icon_password", holderStr: "请输入密码",isName: false)
        bgv.addSubview(passV)
        passV.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(nameV.snp.bottom).offset(17)
            make.size.equalTo(nameV.sdsSize)
        }
        //记住密码
        let passwordSaveBut = UIButton.createButWith(title: "记住密码", titleColor: .white, font: .pingfangSC(15), image: UIImage(named: "icon_weixuanzhong")) { (but) in
            but.isSelected = !but.isSelected
            if !but.isSelected {
                LocalUserInfo.share.sdsPassword = ""
//                LocalUserInfo.share.sdsUserName = ""
//                self.nameF.text = nil
                self.passF.text = nil
            }
            UserDefaults.standard.set(but.isSelected, forKey: savePasswordKey)
        }
        passwordSaveBut.setImage(UIImage(named: "icon_xuanzhong"), for: .selected)
        passwordSaveBut.setButType(type: .imgLeft, padding: 7)
        passwordSaveBut.isSelected = UserDefaults.standard.bool(forKey: savePasswordKey)
        bgv.addSubview(passwordSaveBut)
        passwordSaveBut.snp.makeConstraints { (make) in
            make.top.equalTo(passV.snp.bottom).offset(15)
            make.left.equalTo(passV).offset(20)
        }
        //忘记密码
               let forgetBut = UIButton.createButWith(title: "忘记密码？", titleColor: .white, font: .pingfangSC(15)) { (but) in
                  let vc = PassWordChangeVC()
                if self.navigationController != nil
                {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
               
               }
           
               bgv.addSubview(forgetBut)
               forgetBut.snp.makeConstraints { (make) in
                   make.top.equalTo(passV.snp.bottom).offset(15)
                   make.right.equalTo(passV).offset(-20)
               }
        //登陆按钮
        let backImg = UIImage.CreateGradienImg(colors: [.Hex("#FFFFD26B"),.Hex("#FFF8944B")])
        let loginBut = UIButton.createButWith(title: "立即登陆", titleColor: .white, font: .pingfangSC(20), backGroudImg: backImg) {[weak self] (_) in
            self?.login()
        }
        
        loginBut.sdsSize = CGSize(width: 268.5, height: 46)
        loginBut.cornor(conorType: .allCorners, reduis: 23)
        bgv.addSubview(loginBut)
        loginBut.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(passwordSaveBut.snp.bottom).offset(20)
            make.size.equalTo(loginBut.sdsSize)
        }
        //注册

        let reginBut = UIButton.createButWith(title: "注册新用户", titleColor: .white, font: .pingfangSC(15), image: UIImage(named: "back_more_white")) { (_) in
            let vc = RegisterVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        reginBut.setButType(type:.imgRight,padding:5)
        bgv.addSubview(reginBut)
        reginBut.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(loginBut.snp.bottom).offset(20)
        }
        return bgv
    }
    func createInputView(imgName:String,holderStr:String, isName:Bool = true)->UIView{
        let bgv = UIView()
        bgv.backgroundColor =  .init(white: 0, alpha: 0.2) //.Hex("#CCFFFFFF")
        bgv.sdsSize = CGSize(width: 294, height: 36)
        bgv.cornor(conorType: .allCorners, reduis: 18)
        
        let imgv = UIImageView(image: UIImage(named: imgName))
        bgv.addSubview(imgv)
        //
        let textF = UITextField()
        textF.font = .pingfangSC(16)
        textF.textColor = .white
        textF.placeholder = holderStr
        
        textF.tintColor = .blue
        if isName {
            nameF = textF
        }else{
            passF = textF
            textF.isSecureTextEntry = true
        }
        bgv.addSubview(textF)
        
        imgv.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            
        }
        textF.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(imgv.snp.right).offset(10)
            make.width.equalTo(200)
        }
        
        return bgv
    }
    lazy  var remindL:UILabel = {
        let attrTxt = "注册账号即可享受每日无限观看特权"
        let txt2 = "注册账号即可享受每日无限观看特权,海量成人视频，免费看到爽！"
        let lab = UILabel.createLabWith(title: txt2, titleColor: .white, font: .pingfangSC(15), aligment: .center)
        let attrStr =   txt2.setAttrStr(text: attrTxt, color: .Hex("#FFFED06A"), font: .pingfangSC(15))
        lab.numberOfLines = 0
        lab.attributedText  = attrStr
        return lab
    }()
    lazy var iconv:UIImageView = {
        let imgv = UIImageView(image: UIImage(named: "logo_1"))
        return imgv
    }()
}

//MARK: actions requist
extension LoginVC {
    func login(){
        if !checkLogin() {
            return
        }
        vm.requistLogin(userName: nameF.text!, password: passF.text!, success: {[weak self] in
            SDSHUD.showSuccess("登陆成功")
            if  UserDefaults.standard.bool(forKey: savePasswordKey) {
                LocalUserInfo.share.sdsUserName = self?.nameF.text ?? ""
                LocalUserInfo.share.sdsPassword = self?.passF.text ?? ""
            }
            self?.perform(block: {
              
                    if kAppdelegate.oldRootVC != nil {
                        sdsKeyWindow?.rootViewController = kAppdelegate.oldRootVC
                        kAppdelegate.oldRootVC = nil
                    }else{
                        self?.navigationController?.popViewController(animated: true)
                    }
        
                
            }, timel: 1)
        })
    }
    func checkLogin()->Bool{
        if nameF.text?.count == 0 {
            SDSHUD.showError("用户名不能为空")
            return false
        }
        if passF.text?.count == 0 {
            SDSHUD.showError("密码不能为空")
            return false
        }
        return true
    }
}
