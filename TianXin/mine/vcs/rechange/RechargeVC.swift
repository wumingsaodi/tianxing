//
//  RechargeVC.swift
//  TianXin
//
//  Created by SDS on 2020/9/18.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class RechargeVC: SDSBaseVC {
    let leftRightMarhin:CGFloat = 13
    var selectedMethodBut:UIButton!
    var selectedNumBut:UIButton!
    var selectMoney:String = ""
    var selectedModel:PayTypeModel?
    lazy var vm:RechangeViewModel = {
        return RechangeViewModel()
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "充值中心"
        setUI()
        vm.requistGetPlayTypeList {[weak self] (models) in
            let  newmodes  = models.map({ (model) -> PayTypeModel in
                return  model!
            })
            self?.createPlayMethodView(models: newmodes)
        }
    }
    
    func setUI(){
        let methodLab = createheaderTitle(title: "支付渠道")
        self.view.addSubview(methodLab)
        //
        self.view.addSubview(methodsPayV)
        //
        let moneyLab = createheaderTitle(title: "存款金额")
        self.view.addSubview(moneyLab)
        //
        
        self.view.addSubview(moneyNumV)
        //
        let remindL = createheaderTitle(title: "温馨提示")
        self.view.addSubview(remindL)
        //
        let detailText = "1.充值任意金额就可以免费获得相同金额的K币，充值越多，赠送越多。\n\n2.K币可以通过KOK游戏进行提现，变成人民币。"
        let detaiL = UILabel.createLabWith(title: detailText, titleColor: .Hex("#FF87827D"), font: .pingfangSC(13))
        detaiL.numberOfLines = 0
        self.view.addSubview(detaiL)
        //
        methodLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftRightMarhin)
            make.top.equalToSuperview().offset(KnavHeight + 6)
        }
        methodsPayV.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftRightMarhin)
            make.right.equalToSuperview().offset(-leftRightMarhin)
            make.top.equalTo(methodLab.snp.bottom).offset(6)
//            make.height.equalTo(186)
        }
        moneyLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftRightMarhin)
            make.top.equalTo(methodsPayV.snp.bottom).offset(6)
        }
        moneyNumV.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftRightMarhin)
            make.right.equalToSuperview().offset(-leftRightMarhin)
            make.top.equalTo(moneyLab.snp.bottom).offset(6)
        }
        remindL.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftRightMarhin)
            make.top.equalTo(moneyNumV.snp.bottom).offset(6)
        }
        detaiL.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftRightMarhin)
            make.right.equalToSuperview().offset(-leftRightMarhin)
            make.top.equalTo(remindL.snp.bottom).offset(6)
        }
    }
    
    func createheaderTitle(title:String) -> UILabel {
        let lab = UILabel.createLabWith(title: title, titleColor: .Hex("#FF272727"), font: .pingfangSC(15))
        return lab
    }
    lazy var methodsPayV:UIView = {
        let bgv = UIView()
//        bgv.sdsSize = CGSize(width: 343, height: 190)
        bgv.backgroundColor = .white
        return bgv
    }()
    func createPlayMethodView(models:[PayTypeModel]) {
        methodsPayV.removeSubviews()
        let wh:CGFloat = 70
        let margin:CGFloat = (343 - 70 * 4)/5
        var x :CGFloat = margin
        var y:CGFloat = margin
        for i in 0..<models.count {
            let model = models[i]
            let imgNme = "pay_\(model.paytype)"
            let but = UIButton.createButWith(title: model.tpayname, titleColor: .Hex("#FF87827D"), font: .pingfangSC(10), image: UIImage(named: imgNme)) { [weak self](but) in
                if self!.selectedMethodBut == but {
                    return
                }
                
                let butImgv = but.viewWithTag(102)
                butImgv!.isHidden = false
                but.cornor(conorType: .allCorners, reduis: 4,borderWith: 1,borderColor: mainYellowColor)
                
                self!.selectedMethodBut.cornor(conorType: .allCorners, reduis: 4,borderWith: 1,borderColor: baseVCBackGroudColor_grayWhite)
                let selectedimgv = self!.selectedMethodBut.viewWithTag(102)
                selectedimgv!.isHidden = true
                self?.selectedModel = model
                self?.createZhifuNum(model: model)
                
                self!.selectedMethodBut = but
            }
            but.setButType(type: .imgTop, padding: 5)
            but.cornor(conorType: .allCorners, reduis: 4,borderWith: 1,borderColor: baseVCBackGroudColor_grayWhite)
            let imgv = UIImageView(image: UIImage(named: "xuan_zhong_small"))
            imgv.isHidden = true
            imgv.tag = 102
            but.addSubview(imgv)
            imgv.snp.makeConstraints { (make) in
                make.right.bottom.equalToSuperview()
            }
            if i == 0 {
                but.cornor(conorType: .allCorners, reduis: 4,borderWith: 1,borderColor: mainYellowColor)
                imgv.isHidden = false
                self.selectedMethodBut = but
                self.selectedModel = model
                createZhifuNum(model: model)
            }
            
         
            
            methodsPayV.addSubview(but)
            but.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(x)
                make.top.equalToSuperview().offset(y)
                make.size.equalTo(CGSize(width: wh, height: wh))
                if i == models.count - 1 {
                    make.bottom.equalToSuperview().offset(-14)
                }
            }
            x += margin + wh
            if x > Configs.Dimensions.screenWidth - 20 - margin - wh {
                x = margin
                y += wh + margin
            }
        }
    }
    lazy var moneyNumV:UIView = {
        let bgv = UIView()
//        bgv.sdsSize = CGSize(width: 343, height: 190)
        bgv.backgroundColor = .white
        return bgv
    }()
    func createZhifuNum(model:PayTypeModel) {
        moneyNumV.removeSubviews()
        var titles = model.moneyList.map {return "¥\($0)"}
        if model.isinput == 0 {
            titles.append("其他")
        }
        let width:CGFloat = 70
        let height:CGFloat = 33
        let margin:CGFloat = (343 - 70 * 4)/5
        var x :CGFloat = margin
        var y:CGFloat = margin
        var lastBut:UIButton!
        for i in 0..<titles.count {
            let but = UIButton.createButWith(title: titles[i], titleColor: .Hex("#FF87827D"), font: .pingfangSC(16)) { [weak self](but) in
                if self!.selectedNumBut == but {
                    return
                }
                self?.selectedNumBut.cornor(conorType: .allCorners, reduis: 4,borderWith: 1,borderColor: baseVCBackGroudColor_grayWhite)
                let selectedimgv = self!.selectedNumBut.viewWithTag(102)
                selectedimgv?.isHidden = true
                self?.selectedNumBut.setTitleColor(.Hex("#FF87827D"), for: .normal)
                
                let butImgv = but.viewWithTag(102)
                butImgv?.isHidden = false
                but.setTitleColor(mainYellowColor, for: .normal)
                but.cornor(conorType: .allCorners, reduis: 4,borderWith: 1,borderColor: mainYellowColor)
                self?.selectedNumBut = but
                
                if self?.selectedNumBut.currentTitle ==  "其他"{
                    self?.moneyF.isHidden  = false
                    self?.selectMoney = self!.moneyF.text!
                    self!.moneyF.snp.remakeConstraints { (make) in
                        make.left.equalToSuperview().offset(5)
                        make.right.equalToSuperview().offset(-5)
//                        make.top.equalToSuperview().offset(90)
                        make.top.equalTo(lastBut.snp.bottom).offset(15)
                        make.height.equalTo(45)
                        self?.textFDidChange(tf: self!.moneyF)
                    }
                }else{
                    self?.isSureButEnable(isEnable: true)
                    self?.moneyF.isHidden = true
                    self!.moneyF.snp.remakeConstraints { (make) in
                        make.left.equalToSuperview().offset(5)
                        make.right.equalToSuperview().offset(-5)
//                        make.top.equalToSuperview().offset(90)
                        make.top.equalTo(lastBut.snp.bottom).offset(15)
                        make.height.equalTo(1)
                    }
                    self?.selectMoney = but.currentTitle![1,but.currentTitle!.count - 1]
                }
            }
            but.cornor(conorType: .allCorners, reduis: 4,borderWith: 1,borderColor: baseVCBackGroudColor_grayWhite)
            let imgv = UIImageView(image: UIImage(named: "xuan_zhong_small"))
            imgv.isHidden = true
            imgv.tag = 102
            but.addSubview(imgv)
            if i == 0 {
                but.cornor(conorType: .allCorners, reduis: 4,borderWith: 1,borderColor: mainYellowColor)
                but.setTitleColor(mainYellowColor, for: .normal)
                imgv.isHidden = false
                self.selectMoney = but.currentTitle![1,but.currentTitle!.count - 1]
                self.selectedNumBut = but
            }
            if i ==  titles.count - 1 {
                lastBut = but
            }
            imgv.snp.makeConstraints { (make) in
                make.right.bottom.equalToSuperview()
            }
            
            moneyNumV.addSubview(but)
            but.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(x)
                make.top.equalToSuperview().offset(y)
                make.size.equalTo(CGSize(width: width, height: height))
            }
            x += width + margin
            if x > moneyNumV.sdsW - margin - width {
                x = margin
                y += height + margin
            }
        }
        //
        moneyNumV.addSubview(moneyF)
        moneyF.isHidden = true
        moneyF.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.top.equalTo(lastBut.snp.bottom).offset(15)
            make.height.equalTo(1)
        }
        moneyNumV.addSubview(sureBut)
        sureBut.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(moneyF.snp.bottom).offset(26)
            make.size.equalTo(CGSize(width: 205, height: 38))
            make.bottom.equalToSuperview().offset(-25)
        }
    }
    lazy var moneyF:UITextField = {
        let tf = UITextField()
        tf.textAlignment = .center
        tf.addTarget(self, action: #selector(textFDidChange(tf:)), for: .editingChanged)
        let line = UIView()
        line.backgroundColor = .Hex("#B3E1E1E1")
        line.tag = 1002
        tf.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        return tf
    }()
    lazy var sureBut:UIButton = {
        let backImg = UIImage.createImgWithColor(color: .Hex("#B3E1E1E1"))
        let selectedImg = UIImage.CreateGradienImg(colors: [.Hex("#FFFFD26B"),.Hex("#FFF8944B")])
        let but = UIButton.createButWith(title: "确认充值", titleColor: .Hex("#FFD3D3D3"), font: .pingfangSC(15), backGroudImg: backImg) {[weak self] (but) in
            self?.vm.requistPayDownOrder(tpaysetid: String(self!.selectedModel!.tpaysetid), money: self!.selectMoney, success: {[weak self] in
//                SDSHUD.showSuccess("充值成功")
//                    _ = MoneySuccessPopView.ShowSDSCover()
            })
        }
        but.cornor(conorType: .allCorners, reduis: 19)
        but.isEnabled = true
        but.setBackgroundImage(selectedImg, for: .selected)
        but.setTitleColor(.white, for: .selected)
        but.isSelected = true
        return but
    }()
}
//MARK: - actions
extension RechargeVC {
    @objc func textFDidChange(tf:UITextField){
        let line = tf.viewWithTag(1002)
        if tf.text?.count ?? 0 > 0 {
            sureBut.isEnabled = true
            sureBut.isSelected = true
            line?.backgroundColor = .red
        }else{
            sureBut.isEnabled = false
            sureBut.isSelected = false
            line?.backgroundColor = .Hex("#B3E1E1E1")
        }
    }
    func isSureButEnable(isEnable:Bool){
        if isEnable {
            sureBut.isEnabled = true
            sureBut.isSelected = true
        }else{
            sureBut.isEnabled = false
            sureBut.isSelected = false
        }
    }
}
