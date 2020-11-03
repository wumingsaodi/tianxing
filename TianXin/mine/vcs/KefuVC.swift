//
//  KefuVC.swift
//  TianXin
//
//  Created by SDS on 2020/9/18.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class KefuVC: SDSBaseVC {
    var userModel:UserInfoModel?
    let textvColor:UIColor = .black
    let placeHodler = "请在此输入您遇到的问题，我们会安排专人为您解答～"
    let placeHolderColor:UIColor = .init(hex: 0xACABAA)
   var typeButTitles =  ["账号问题","充值问题","提款问题","密码问题","银行卡问题","其他问题"]
    var selectedTypeBut:UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "客服中心"
       setUI()
        LocalUserInfo.share.getLoginInfo { [weak self] (model) in
            self?.userModel = model
            self?.phoneF.text = LocalUserInfo.share.showPhoto
            self?.emailF.text = LocalUserInfo.share.showEmail
        }
    }
    func setUI(){
        let typeLab = UILabel.createLabWith(title: "问题类型", titleColor: .Hex("#87827D"), font: .pingfangSC(15))
        self.view.addSubview(typeLab)
        //
        let typeV = createTypeButV()
        self.view.addSubview(typeV)
        //
        self.view.addSubview(yiJianTextV)
        //
        let connectLab = UILabel.createLabWith(title: "您的联系方式", titleColor: .Hex("#FF87827D"), font: .pingfangSC(15))
        self.view.addSubview(connectLab)
        //
        self.view.addSubview(emailF)
        self.view.addSubview(phoneF)
        self.view.addSubview(sureBut)
        typeLab.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8.5 + KnavHeight)
            make.left.equalToSuperview().offset(18)
        }
        typeV.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(typeLab.snp.bottom).offset(7)
            make.height.equalTo(100.5)
        }
        yiJianTextV.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(typeV.snp.bottom).offset(14.5)
            make.height.equalTo(150)
        }
        connectLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(yiJianTextV.snp.bottom).offset(14)
        }
        emailF.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(connectLab.snp.bottom).offset(10)
            make.height.equalTo(36)
        }
        phoneF.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(emailF.snp.bottom).offset(10)
            make.height.equalTo(36)
        }
        sureBut.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(phoneF.snp.bottom).offset(30)
            make.size.equalTo(CGSize(width: 205, height: 38))
        }
    }
    lazy var yiJianTextV:UITextView = {
        let textv = UITextView()
        textv.text = placeHodler
        textv.textColor = placeHolderColor
        let lab = UILabel.createLabWith(title: "0/200", titleColor: .Hex("#87827D"), font: .pingfangSC(12))
        lab.tag = 1001
        textv.addSubview(lab)
        lab.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-18.5)
            make.bottom.equalToSuperview().offset(-10)
        }
//        textv.addtage
//        textv.addDoneOnKeyboardWithTarget(self, action: #selector(textVDidChange))
        textv.delegate = self
        return textv
    }()
    lazy var emailF:UITextField = {
       let textF = UITextField()
        textF.placeholder = "邮箱"
        textF.layer.borderWidth = 1
        textF.layer.borderColor = UIColor.gray.cgColor
        return textF
    }()
    lazy var phoneF:UITextField = {
       let textF = UITextField()
        textF.placeholder = "手机"
        textF.layer.borderWidth = 1
        textF.layer.borderColor = UIColor.gray.cgColor
        return textF
    }()
    
    lazy var sureBut:UIButton = {
        let but = UIButton.createButWith(title: "提交", titleColor: .white, font: .pingfangSC(15), backGroudImg: mainYellowGradienImg) {[weak self] (but) in
            let phone = self!.phoneF.text == LocalUserInfo.share.showPhoto ? self!.userModel?.phone : self!.phoneF.text
            let email =  self!.emailF.text == LocalUserInfo.share.showEmail ? self?.userModel?.email : self!.emailF.text
            NetWorkingHelper.normalPost(url: "/gl/customer/askProblem", params: ["type":self?.selectedTypeBut.currentTitle ?? "","content":self?.yiJianTextV.text ?? "","contactType":email ?? "","contactTxt":phone ?? ""]) { (dict) in
              _ =  KeFuSuccessPopView.ShowSDSCover()
//                SDSHUD.showSuccess("您的问题已经成功反馈到客服那里了")
            }
        }
        but.cornor(conorType: .allCorners, reduis: 19)
        return but
    }()
    func createTypeButV() -> UIView {
        let bgv = UIView()
        bgv.backgroundColor = .white
        let buth:CGFloat = 30
        let butw:CGFloat = 100
        let margin:CGFloat = (Configs.Dimensions.screenWidth - butw*3)/5
        var x:CGFloat = margin
        var y:CGFloat = 14
        for i in 0..<typeButTitles.count {
            let but = UIButton.createButWith(title: typeButTitles[i], titleColor: .Hex("#87827D"), font: .pingfangSC(15), backGroudImg: UIImage.createImgWithColor(color: .Hex("#E7E7E8"))) {[weak self] (but) in
                if but == self?.selectedTypeBut{
                    return
                }
                self?.selectedTypeBut.isSelected = false
                but.isSelected = true
                self?.selectedTypeBut = but
            }
            but.setBackgroundImage(UIImage.CreateGradienImg(colors: [.Hex("#FFD26B"),.Hex("#F8944B")]), for: .selected)
            but.setTitleColor(.white, for: .selected)
            but.cornor(conorType: .allCorners, reduis: buth*0.5)
            bgv.addSubview(but)
            but.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(x)
                make.top.equalToSuperview().offset(y)
                make.height.equalTo(buth)
                make.width.equalTo(butw)
            }
            if i == 0 {
                self.selectedTypeBut = but
                but.isSelected = true
            }
            x += margin + butw
            if x > Configs.Dimensions.screenWidth - butw - margin {
                x = margin
                y += 14 + buth
            }
        }
        return bgv
    }
}

//MARK: - actions
extension KefuVC:UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = textvColor
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.count <= 0 {
            textView.textColor = placeHolderColor
            textView.text = placeHodler
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        textVDidChange()
    }
    @objc func textVDidChange(){
        if yiJianTextV.text.count > 0 {
            yiJianTextV.text = yiJianTextV.text.replacingOccurrences(of: placeHodler, with: "")
            yiJianTextV.textColor = textvColor
        }else{
            yiJianTextV.textColor = placeHolderColor
            yiJianTextV.text = placeHodler
        }
        let lab  = yiJianTextV.viewWithTag(1001) as! UILabel
        lab.text = "\(yiJianTextV.text.count)/200"
        if yiJianTextV.text.count > 200 {
            yiJianTextV.text = yiJianTextV.text[0,200]
        }
    }
}
