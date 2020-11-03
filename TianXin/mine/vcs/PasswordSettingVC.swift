//
//  PasswordSettingVC.swift
//  TianXin
//
//  Created by SDS on 2020/9/28.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class PasswordSettingVC: SDSBaseVC {
    var code:String!
    var phone:String!
    lazy var vm:UserInfoViewModel = {
        return UserInfoViewModel()
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
           title = "设置登陆密码"
        setUI()
    }
    init(code:String,phoneOrEmail:String) {
        super.init(nibName: nil, bundle: nil)
        self.code = code
        self.phone = phoneOrEmail
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUI() {
        let bgv = UIView()
        bgv.backgroundColor = .white
        //
        self.view.addSubview(bgv)
       
       //
        let passV = createPassView()
        self.view.addSubview(passV)
        passV.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(195*0.5)
            make.top.equalToSuperview().offset(10 + KnavHeight)
        }
        //
        let aginPassV = createPassView(isAgin: true)
        self.view.addSubview(aginPassV)
        aginPassV.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(passV.snp.bottom)
            make.height.equalTo(passV)
        }
        //
        self.view.addSubview(sureBut)
        sureBut.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(aginPassV.snp.bottom).offset(50)
            make.size.equalTo(CGSize(width: 205, height: 38))
        }
    }
    func createPassView(isAgin:Bool = false) -> UIView {
        let bgv = UIView()
        bgv.backgroundColor = .white
         let lab = UILabel.createLabWith(title: "密码", titleColor: .Hex("#FF3B372B"), font: .pingfangSC(17))
        bgv.addSubview(lab)
        lab.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(23)
            make.left.equalToSuperview().offset(20)
        }
        let tf  = UITextField()
        tf.font = .pingfangSC(15)
        tf.isSecureTextEntry = true
        tf.textAlignment = .left
        bgv.addSubview(tf)
        tf.snp.makeConstraints { (make) in
            make.top.equalTo(lab.snp.bottom).offset(9)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-10)
        }
        tf.addTarget(self, action: #selector(textFdidChange), for: .editingChanged)
        let visiableBut = createVisitedBut()
        tf.addSubview(visiableBut)
        visiableBut.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
            make.height.equalToSuperview()
            make.width.equalTo(50)
        }
        if isAgin {
            lab.text = "请确认新密码"
            //
            self.aginPassF = tf
            tf.placeholder = "请确认新密码"
        }else{
            
            //
            tf.placeholder = "请输入6-12位字母或数字"
            self.passF = tf
            let line = UIView()
            bgv.addSubview(line)
            line.backgroundColor = baseVCBackGroudColor_grayWhite
            line.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(1)
            }
        }
        return bgv
    }
    func createVisitedBut() -> UIButton {
            let but = UIButton.createButWith(image: UIImage(named: "liulanliang")) { (but) in
                but.isSelected = !but.isSelected
                let tf = but.superview as! UITextField
                if(but.isSelected) {
                   
                    tf.isSecureTextEntry = false
                }else{
                    tf.isSecureTextEntry  = true
                }
            }
            but.setImage(UIImage(named: "icon_unvisible"), for: .selected)
            return but
    }
    var passF:UITextField!
    var aginPassF:UITextField!
   
    lazy var sureBut:UIButton = {
        let backImg = UIImage.createImgWithColor(color: .Hex("#B3E1E1E1"))
        let selectedImg = UIImage.CreateGradienImg(colors: [.Hex("#FFFFD26B"),.Hex("#FFF8944B")])
        let but = UIButton.createButWith(title: "确认", titleColor: .Hex("#FFD3D3D3"), font: .pingfangSC(15), backGroudImg: backImg) { [weak self] (but) in
            self?.reset()
        }
        but.cornor(conorType: .allCorners, reduis: 19)
        but.isEnabled = false
        but.setBackgroundImage(selectedImg, for: .selected)
        but.setTitleColor(.white, for: .selected)
        return but
    }()
    @objc func textFdidChange(){
        if passF.text?.count ?? 0 > 0 && aginPassF.text?.count ?? 0 > 0{
            sureBut.isSelected = true
            sureBut.isEnabled = true
        }else {
            sureBut.isSelected = false
            sureBut.isEnabled = false
        }
    }
}


//MARK: - actions
extension PasswordSettingVC{
    func checkAvilibale() ->Bool{
        if passF.text != aginPassF.text! {
            SDSHUD.showError("两次输入的验证码不一样，重清新输入")
            aginPassF.text = nil
            return false
        }
        return true
    }
    func reset()  {
vm.resetPassword(code: code, password: passF.text!, aginPassword:aginPassF.text!, phoneOrEmail: phone) {[weak self] (error) in
    SDSHUD.showError(error.errMsg)
        self?.navigationController?.popViewController(animated: true)
    }
    }
}
