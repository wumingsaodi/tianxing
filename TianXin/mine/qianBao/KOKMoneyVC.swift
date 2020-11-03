//
//  KOKMoneyVC.swift
//  TianXin
//
//  Created by SDS on 2020/10/1.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class KOKMoneyVC: SDSBaseVC {
    @IBOutlet weak var remindV: UIView!
    @IBOutlet weak var butsV: UIView!
    @IBOutlet weak var tianXingMoneyLab: UILabel!
    @IBOutlet weak var kokMoneyLab: UILabel!
    @IBOutlet weak var sureBut: UIButton!
    var balance:UserBalance?
    @IBOutlet weak var moneyF: UITextField!
    var selectedBut:UIButton?
    lazy var vm:KOKMoneyVCViewModel = {
        return  KOKMoneyVCViewModel()
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.sureBut.cornor(conorType: .allCorners, reduis: 19)
        let backimg = UIImage.CreateGradienImg(colors: [.Hex("#FFFFD26B"),.Hex("#FFF8944B")])
        sureBut.setBackgroundImage(backimg, for: .normal)
        createMoneyButs()
        LocalUserBalance.share.getUserBalance { [weak self](balance) in
            self?.balance = balance
            self?.tianXingMoneyLab.text = String(format: "%0.2f", balance.balance)
            self?.kokMoneyLab.text  = String(format: "%0.2f", balance.totalAssets)
            self!.remindV.isHidden = balance.balance > 50.0
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setWhiteBackImg(title:"转账")
    }
    @IBAction func sureButClick(_ sender: UIButton) {
        if Float(moneyF.text ?? "") == nil {
            SDSHUD.showError("请输入合法的金额")
            return
        }
        if Float(moneyF.text ?? "0") ?? 0 > balance?.balance ?? 0 {
            SDSHUD.showError("输入金额不能超过余额")
            return
        }
        vm.changeMoneyToKok(amount: moneyF.text ?? "0")
    }
    @IBAction func HelpClick(_ sender: UIButton) {
        let  vc = KefuVC()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    func createMoneyButs(){
        let butw :CGFloat = 80
        let buth:CGFloat = 35
        let margin:CGFloat = (Configs.Dimensions.screenWidth - butw*3 -  20) / 2
        let marginY:CGFloat = 12
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
            butsV.addSubview(but)
            but.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(y)
                make.left.equalToSuperview().offset(x)
                make.size.equalTo(CGSize(width: butw, height: buth))
            }
//            if i == 0 {
//
//            }
            x += margin + butw
            if x > Configs.Dimensions.screenWidth - 20 - butw {
                x = 0
                y += buth + marginY
            }
        }
    }
    
}
