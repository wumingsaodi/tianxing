//
//  RegisterVC.swift
//  TianXin
//
//  Created by SDS on 2020/9/26.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class RegisterVC: SDSBaseVC {
    var nameF:UITextField!
    var passF:UITextField!
    var yaoqingF:UITextField!
    var codeF:UITextField!
    lazy var vm:LoginViewModel = {
        let vm = LoginViewModel()
        return vm
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCode()
      setUI()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.setWhiteBackImg()
    }
    /**
     ui
     */
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
            make.size.equalTo(CGSize(width: 320, height: 373))
        }
        //
        let visitedBut = UIButton.createButWith(title: "返回登陆", titleColor: .white, font: .pingfangSC(16)) { [weak self](_) in
            self?.navigationController?.popViewController(animated: true)
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
        let loginL = UILabel.createLabWith(title: "注册", titleColor: .white, font: .pingfangSC(25))
        
        bgv.addSubview(loginL)
        loginL.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(25)
        }
        //
        let nameV = createInputView(imgName: "icon_user", holderStr: "请输入用户名")
         nameF = nameV.viewWithTag(1001) as? UITextField
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
        let yaoQingv = createInputView(imgName: "icon_Invitation code", holderStr: "邀请码（选填）")
        yaoqingF = yaoQingv.viewWithTag(1001) as? UITextField
        bgv.addSubview(yaoQingv)
        yaoQingv.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(passV.snp.bottom).offset(17)
            make.size.equalTo(yaoQingv.sdsSize)
        }
        
        let codev = createInputView(imgName: "icon_Captcha", holderStr: "请输入验证码")
        codeF = codev.viewWithTag(1001) as? UITextField
        bgv.addSubview(codev)
        codev.snp.makeConstraints { (make) in
                  make.centerX.equalToSuperview()
                  make.top.equalTo(yaoQingv.snp.bottom).offset(17)
                  make.size.equalTo(codev.sdsSize)
              }
        codev.addSubview(sdsCodev)
        sdsCodev.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
            make.size.equalTo(CGSize(width: 56.5, height: 25))
        }
        
        
        
        //立即注册
        let backImg = UIImage.CreateGradienImg(colors: [.Hex("#FFFFD26B"),.Hex("#FFF8944B")])
        let loginBut = UIButton.createButWith(title: "立即注册", titleColor: .white, font: .pingfangSC(20), backGroudImg: backImg) {[weak self] (_) in
            self?.regiseter()
        }
        loginBut.sdsSize = CGSize(width: 268.5, height: 46)
        loginBut.cornor(conorType: .allCorners, reduis: 23)
        bgv.addSubview(loginBut)
        loginBut.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(codev.snp.bottom).offset(20)
            make.size.equalTo(loginBut.sdsSize)
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
        textF.tag = 1001
        if isName {
//            nameF = textF
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
    lazy var sdsCodev:UIImageView = {
          let codev = UIImageView()
          return codev
      }()
//    lazy var sdsCodev:SDSCodeView = {
//        let codev = SDSCodeView(isFromeNet: false)
//        codev.refreshBlock = {[weak self](finishBlock) in
//            LoginViewModel.share.requistRandomCodes { (titles) in
//                finishBlock(titles)
//            }
//
//        }
//        codev.backgroundColor = .white
//        return codev
//    }()
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
//MARK: -actions 网络请求
extension RegisterVC {
    func getCode(){
        vm.requistRandomCodes { [weak self](key,img) in
            self!.sdsCodev.image = img
        }
    }
    func regiseter(){
        if BeforereisterYanzheng() == false {
            return
        }
        vm.requistRegisterUse(userNameuser: nameF.text!, password: passF.text!, inviteCode: yaoqingF.text ?? "",code: codeF.text ?? "",success:{[weak self] in
            SDSHUD.showSuccess("注册成功")
            self?.perform(block: {
                self?.navigationController?.popViewController(animated: true)
            }, timel: 2)

        },fail: { [weak self]_ in
            self?.perform(block: {
                self?.codeF.text = ""
                self?.getCode()
            }, timel: 1.5)
            
        })
    }
    func BeforereisterYanzheng() -> Bool {
        if nameF.text?.count == 0   || nameF.text ?? "" == "" {
            SDSHUD.showError("名称不能为空")
            return false
        }
        if passF.text?.count == 0 || passF.text ?? "" == ""{
            SDSHUD.showError("密码不能为空")
            return false
        }
        if codeF.text?.count == 0 || codeF.text ?? "" == ""{
            SDSHUD.showError("验证码不能为空")
            return false
        }
        return true
    }
}
