//
//  MineSignatureVC.swift
//  TianXin
//
//  Created by SDS on 2020/9/29.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

import UIKit

import LCTextView
import RxSwift
import RxCocoa

class MineSignatureVC: SDSBaseVC {
    lazy var vm:UserInfoViewModel = {
        return UserInfoViewModel()
    }()
//    var willBackBlock:((_ sign:String)->Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "修改个性签名"
        setUI()
        
        let textValid = nameF.rx.text.orEmpty.map { $0.count >= 1 }.share(replay: 1)
        textValid.bind(to: sureBut.rx.isEnabled).disposed(by: rx.disposeBag)
        
        LocalUserInfo.share.getLoginInfo {[weak self] (model) in
            if let model = model {
                self!.nameF.text = model.userSign
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
     
    }
    
    func setUI(){
        let lab = UILabel.createLabWith(title: "个性签名", titleColor: .Hex("#FF3B372B"), font: .pingfangSC(17))
        self.view.addSubview(lab)
        lab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(22)
            make.top.equalToSuperview().offset(KnavHeight)
            make.height.equalTo(47)
        }
        
        self.view.addSubview(bgView)
        bgView.addSubview(nameF)
        
        let numLab = UILabel.createLabWith(title: "\(nameF.text?.count ?? 0)/100", titleColor: .Hex("#FF87827D"), font: .pingfangSC(16))
        numLab.tag = 102
        bgView.addSubview(numLab)
        numLab.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-12)
            make.right.equalToSuperview().offset(-12)
        }
        
        let text = "内容不允许出现数字和英文字母"
        let remindL = UILabel.createLabWith(title: text, titleColor: .Hex("#FF87827D"), font: .pingfangSC(15))
        remindL.numberOfLines = 0
        self.view.addSubview(remindL)

        self.view.addSubview(sureBut)
        sureBut.snp.makeConstraints { (make) in
            make.top.equalTo(remindL.snp.bottom).offset(82)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 205, height: 38))
        }
        
        bgView.snp.makeConstraints { (make) in
            make.top.equalTo(lab.snp.bottom)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(210)
        }
        nameF.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(13)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(150)
//            make.top.equalTo(lab.snp.bottom)
//            make.left.equalToSuperview().offset(16)
//            make.right.equalToSuperview().offset(-16)
//            make.height.equalTo(210)
//            make.centerX.equalToSuperview()
            
//            make.size.equalTo(CGSize(width: 343, height: 210))
        }
        remindL.snp.makeConstraints { (make) in
            make.top.equalTo(bgView.snp.bottom).offset(14)
            make.left.equalToSuperview().offset(22)
        }
    }
    
    lazy var sureBut:UIButton = {
        let rightBut = UIButton.createButWith(title: "确定", titleColor: .white, font: .pingfangSC(15)) {[weak self] (but) in
            if self?.nameF.text?.count ?? 0 < 0{
                SDSHUD.showError("签名不能为空")
                return
            }
//            if let block = self?.willBackBlock {[]
            self?.vm.uploadUserInfo(userSign: self!.nameF.text!, success: {[weak self] (_) in
                SDSHUD.showSuccess("个人签名修改成功改成功")
                self?.navigationController?.popViewController(animated: true)
            })
                
//            }
        }
        rightBut.setBackgroundImage(UIImage(named: "mine_sureBut"), for: .normal)
        return rightBut
    }()
    
    lazy var bgView:UIView = {
        let bView:UIView = UIView()
        bView.layer.cornerRadius = 10.0
        bView.backgroundColor = .white
        return bView
    }()
    
    lazy var nameF:LCTextView = {
        let tv = LCTextView()
        tv.backgroundColor = .white
        tv.placeholder = "输入个性签名能让别人更好的认识你哟"
        tv.textColor = .Hex("#FF3B372B")
        tv.font = .pingfangSC(17)
        tv.delegate = self
        tv.textAlignment = .left
//        tv.addTarget(self, action: #selector(nickTextFieldDidChange(tf:)), for: .editingChanged)
    return tv
    }()
    
    @objc func nickTextFieldDidChange(tf:UITextField){
        if tf.text?.count ?? 0 > 100 {
            tf.text = tf.text![0,100]
        }
        let lab = bgView.viewWithTag(102) as! UILabel
        lab.text = "\(tf.text!.count)/100"
    }
    deinit {
        NJLog("\(self)--dddddd")
    }
}

extension MineSignatureVC:UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        //文本视图内容改变时，触发本方法,如果是回车符号，则textView释放第一响应值，返回false

         if (text ==  "\n") {

             textView.resignFirstResponder()

             return false;

         }
        if textView.text?.count ?? 0 > 100 {
            textView.text = textView.text![0,100]
        }
        let currentText = textView.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: text)
        let str = newText as NSString
        
        let lab = bgView.viewWithTag(102) as! UILabel
        lab.text = "\(str.length)/100"
        
         return true

    }
  
}
