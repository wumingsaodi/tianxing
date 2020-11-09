//
//  HomeChongzhiView.swift
//  TianXin
//
//  Created by SDS on 2020/10/29.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
let NoHomeMoenyPopShow = "NoHomeMoenyPopShow"
class HomeChongzhiView: UIView {
    
    
    @IBOutlet weak var kokMoneyL: UILabel!
    @IBOutlet weak var reamindV: UIView!
    @IBOutlet weak var balaceL: UILabel!
    
    @IBOutlet weak var moneyF: UITextField!
    @IBOutlet weak var zhuanZhangBut: UIButton!
    @IBOutlet weak var butsv: UIView!
    var selectedBut:UIButton?
    var balance :UserBalance?
    override  func awakeFromNib() {
        super.awakeFromNib()
        zhuanZhangBut.setBackgroundImage(UIImage.CreateGradienImg(colors: [.init(hex: 0xFFD26B),.init(hex: 0xF8944B)]), for: .normal)
        createMoneyButs()
        moneyF.keyboardType = .numberPad
        LocalUserBalance.share.getUserBalance {[weak self] (balace) in
            self!.balance = balace
            self?.balaceL.text = "¥\(balace.balance)"
            self?.kokMoneyL.text = "¥\(balace.totalAssets)"
        }
    }
    func createMoneyButs(){
        let butw :CGFloat = 70
        let buth:CGFloat = 28
        let margin:CGFloat = (250 - butw*3 ) / 2
        let marginY:CGFloat = 6
        var x :CGFloat = 0
        var  y:CGFloat = 0
        let  titles = ["50","100","500","1000","2000","全部"]
        for i in 0..<6{
            let  but = UIButton.createButWith(title: titles[i], titleColor: .Hex("#3B3B3B"), font: .pingfangSC(20),backGroudImg: UIImage.createImgWithColor(color: .Hex("#F2F2F2"))) {[weak self] (but) in
                if self?.selectedBut == but {
                    return
                }
                if but.currentTitle == titles.last {
                    self?.moneyF.text = "\(self?.balance?.balance ?? 0)"
                }else{
                    self?.moneyF.text = but.currentTitle
                }
                self?.selectedBut?.isSelected = false
                but.isSelected = true
                self?.selectedBut = but
            }
            but.setBackgroundImage(mainYellowGradienImg, for: .selected)
            butsv.addSubview(but)
            but.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(y)
                make.left.equalToSuperview().offset(x)
                make.size.equalTo(CGSize(width: butw, height: buth))
            }
//            if i == 0 {
//
//            }
            x += margin + butw
            if x > 270 - 20 - butw {
                x = 0
                y += buth + marginY
            }
        }
    }
    @IBAction func noRemindButClick(_ sender: UIButton) {
//        UserDefaults.standard.setValue(<#T##value: Any?##Any?#>, forKey: <#T##String#>)
        UserDefaults.standard.setValue(Date().timeIntervalSince1970, forKey: NoHomeMoenyPopShow)
        if   let superV = self.superview as? SDSBaseCoverPopView{
            superV.cancel()
        }
    }
    
    @IBAction func butClick(_ sender: UIButton) {
       
        if sender.currentTitle == "确认转账"{
            if Float(moneyF.text ?? "") ?? 0 <= 0 {
                SDSHUD.showError("请输入正确的转账金额")
                return
            }
            if Float(moneyF.text ?? "0")! >  (balance?.balance ?? 0)  {
                SDSHUD.showError("转账金额不能超过余额")
                return
            }
            
            let vm = KOKMoneyVCViewModel()
            vm.changeMoneyToKok(amount: moneyF.text ?? "0"){
                if   let superV = self.superview as? SDSBaseCoverPopView{
                    superV.cancel()
                }
            }
        } else if  sender.currentTitle == "立即充值"{
            if   let superV = self.superview as? SDSBaseCoverPopView{
                superV.cancel()
            }
            let vc = RechargeVC()
            kAppdelegate.getNavvc()?.pushViewController(vc, animated: true)
           
           
        } else if  sender.currentTitle == "进入游戏"{
            if !kAppdelegate.islogin() {
                return
            }
            NetWorkingHelper.normalPost(url: "/gl/user/getAppHome", params: [:]) { (dict) in
                guard let url = dict["data"] as? String else{
                    return
                }
                LocalUserInfo.share.getLoginInfo { (model) in
                
                }
                let gameUrl  = url + "?token=" + (LocalUserInfo.share.sessionId  ?? "")
                if   let superV = self.superview as? SDSBaseCoverPopView{
                    superV.cancel()
                }
                let webVc = SDSBaseWebVC.init(url: gameUrl)
                kAppdelegate.getNavvc()?.pushViewController(webVc, animated: true)
                
            }
            
        }
    
    }
    
    
    
    
    
    
}
