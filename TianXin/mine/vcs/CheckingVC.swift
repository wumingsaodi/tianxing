//
//  CheckingVC.swift
//  TianXin
//
//  Created by SDS on 2020/9/28.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
enum checkVCbgvType:Int{
    case photo = 0
    case tuxing = 1
    case num = 2
}
class CheckingVC: SDSBaseVC {
    var secoeds:Int = 60
    var timer:Timer?
    var photoLtext:String = "手机号"
    /**
     手机号或邮箱
     */
    var phonNum:String = ""
    var realPhoneNum:String = ""
    var tuxingCodeF:UITextField!
    var numCodeF:UITextField!
    var isPhoto:Bool = true
    var isSendIphoneCode:Bool = false
    lazy var loginvm = {
        return LoginViewModel()
    }()
    lazy var infovm = {
        return UserInfoViewModel()
    }()
    init(text:String,isPhoto:Bool = true) {
        super.init(nibName: nil, bundle: nil)
        self.isPhoto = isPhoto
        self.phonNum = text
        realPhoneNum = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "验证身份"
        setUI()
        loginvm.requistRandomCodes { (_, img) in
            self.codeView.image = img
        }
    }
    func setUI(){
        if !isPhoto {
            photoLtext = "邮箱"
            let attrs  = phonNum.components(separatedBy: "@")
            if attrs.count == 1 {
                phonNum =  attrs[0][0,3] + "****" + attrs[0][attrs.count-2,2]
            }else{
               phonNum =  attrs[0][0,3] + "****" + attrs[0][attrs.count-2,2] + "@" + attrs[1]
            }
           
        }else{
             phonNum = phonNum[0,3] + "****" + phonNum[7,4]
        }
        //
        let  photov = createbgV(title: photoLtext, type: .photo, subView: nil)
        self.view.addSubview(photov)
        let tuxingv = createbgV(title: "图形验证码", type: .tuxing, subView: codeView)
        self.view.addSubview(tuxingv)
        let numcodev = createbgV(title: "获取验证码", type: .num, subView: yanzhengBut)
        self.view.addSubview(numcodev)
        self.view.addSubview(sureBut)
        
        photov.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(100)
            make.top.equalToSuperview().offset(KnavHeight + 10)
        }
        tuxingv.snp.makeConstraints { (make) in
                  make.left.right.equalToSuperview()
                  make.height.equalTo(100)
            make.top.equalTo(photov.snp.bottom)
              }
        numcodev.snp.makeConstraints { (make) in
                  make.left.right.equalToSuperview()
                  make.height.equalTo(100)
            make.top.equalTo(tuxingv.snp.bottom)
              }
        sureBut.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(numcodev.snp.bottom).offset(50)
            make.size.equalTo(CGSize(width: 205, height: 38))
              }
        
    }
    func createbgV(title:String,type:checkVCbgvType,subView:UIView? )->UIView{
        let bgv = UIView()
        bgv.backgroundColor = .white
        let titleL = UILabel.createLabWith(title: title, titleColor: .Hex("#FF3B372B"), font: .pingfangSC(17))
        
        let tf = UITextField()
        tf.font = .pingfangSC(15)
        tf.addTarget(self, action: #selector(textFdidChange), for: .editingChanged)
        let line = UIView()
        line.backgroundColor = baseVCBackGroudColor_grayWhite
        
        switch type {
        case .photo:
            tf.text = phonNum
            tf.isUserInteractionEnabled = false
        case .tuxing:
            tf.placeholder = "请输入图形验证码"
            tuxingCodeF = tf
        default:
            tf.placeholder  = "请输入验证码"
            line.isHidden = true
            numCodeF = tf
        }
        bgv.addSubview(titleL)
        titleL.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(23)
            make.left.equalToSuperview().offset(25)
        }
        bgv.addSubview(tf)
        tf.snp.makeConstraints { (make) in
            make.top.equalTo(titleL.snp.bottom).offset(23)
            make.left.equalToSuperview().offset(25)
        }
        bgv.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
        if subView != nil {
            bgv.addSubview(subView!)
            subView!.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.right.equalToSuperview().offset(-25)
                if (subView?.isKind(of: SDSCodeView.self))!{
                    make.size.equalTo(CGSize(width: 72, height: 30))
                }
            }
            
        }
        bgv.addSubview(tf)
        return bgv
    }
   lazy var codeView : UIImageView = {
        return  UIImageView()
    }()
//    lazy var codeView:SDSCodeView = {
//        let view = SDSCodeView(isFromeNet: true)
//        view.refreshBlock = { [weak self](fishiBlock) in
//
//
//        }
//        view.backgroundColor = .Hex("#FFF8F8F8")
//        return view
//    }()
    lazy var yanzhengBut:UIButton = {
        let but = UIButton.createButWith(title: "获取验证码", titleColor: mainYellowColor, font: .pingfangSC(15)) {[weak self] (but) in
            self?.RandomCodeCheck()
        }
        but.cornor(conorType: .allCorners, reduis: 5,borderWith: 1,borderColor: mainYellowColor)
        return but
    }()
    lazy var sureBut:UIButton = {
        let backImg = UIImage.createImgWithColor(color: .Hex("#B3E1E1E1"))
        let selectedImg = UIImage.CreateGradienImg(colors: [.Hex("#FFFFD26B"),.Hex("#FFF8944B")])
        let but = UIButton.createButWith(title: "下一步", titleColor: .Hex("#FFD3D3D3"), font: .pingfangSC(15), backGroudImg: backImg) {[weak self] (but) in
            self?.sureButClick()
        }
        but.cornor(conorType: .allCorners, reduis: 19)
        but.isEnabled = false
        but.setBackgroundImage(selectedImg, for: .selected)
        but.setTitleColor(.white, for: .selected)
        return but
    }()
    @objc func textFdidChange(){
        if tuxingCodeF.text?.count ?? 0 > 0 && numCodeF.text?.count ?? 0 > 0{
            sureBut.isSelected = true
            sureBut.isEnabled = true
        }else {
            sureBut.isSelected = false
            sureBut.isEnabled = false
        }
    }
    deinit {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
}


//MARK: - 请求
extension CheckingVC {
    func getTuxingCode(){
        loginvm.requistRandomCodes {[weak self] (_, img) in
            self?.codeView.image = img
        }
    }
    func RandomCodeCheck() {
        if  tuxingCodeF.text?.count ?? 0 == 0 {
            SDSHUD.showError("请输入图像验证码")
            return
        }
        loginvm.checkRandomCode(code: tuxingCodeF.text!,success: {[weak self] in
            self?.getPhoneOrEmailCode()
        }){ [weak self] in
            self?.getTuxingCode()
            self?.tuxingCodeF.text = nil
        }
    }
    func getPhoneOrEmailCode() {
        if isPhoto {
            infovm.requistSendPhoneCode(phone: realPhoneNum){//[weak self] in
//                self?.startTimer()
//                self?.sureBut.isEnabled = true
            }
        }else{
            infovm.requistSendEmailCode(email:realPhoneNum){ //[weak self] in
//                self?.startTimer()
            }
        }
        self.startTimer()
    }
    func sureButClick(){
        if !isSendIphoneCode {
            SDSHUD.showError("您尚未发生获取手机或邮箱验证码")
            return
        }
        let  vc = PasswordSettingVC(code: self.numCodeF.text ?? "" ,phoneOrEmail: realPhoneNum)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func startTimer(){
        isSendIphoneCode = true
        let but = yanzhengBut
        but.isEnabled = false
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {[] (timer) in
            
            self.secoeds -= 1
            if self.secoeds < 0 {
                self.secoeds = 60
                timer.invalidate()
                but.setTitle("获取验证码", for: .normal)
                but.isEnabled = true
                but.setTitleColor(mainYellowColor, for: .normal)
                but.cornor(conorType: .allCorners, reduis: 5,borderWith: 1,borderColor: mainYellowColor)
            }else{
                but.setTitle("\(self.secoeds)秒获取", for: .normal)
                but.setTitleColor(.gray, for: .normal)
                but.cornor(conorType: .allCorners, reduis: 5,borderWith: 1,borderColor: .gray)
            }
        }
    }
}
