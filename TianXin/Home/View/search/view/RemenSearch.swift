//
//  RemenSearch.swift
//  TianXin
//
//  Created by SDS on 2020/9/22.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import SnapKit
let LastestVideoSearchArrKey = "LastestVideoSearchArrKey"
let serachShakeAnimal = "serachShakeAnimal"
class RemenSearch: UIView {
    var useSaveKey:String = LastestVideoSearchArrKey
    var titleButs:[UIButton] = [UIButton]()
    var titles:[String]!{
        didSet{
            if titles.count > 0 {
                createRemenView(titles: titles)
            }
           
        }
    }
    var didSelectedBlock:((String)->Void)?
    init(frame: CGRect,titles:[String],didSelectedBlock:@escaping (String)->Void) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.titles = titles
        self.didSelectedBlock = didSelectedBlock
    
        setUI()
    }

    func  setUI()  {
        let  tap = UITapGestureRecognizer.init(target: self, action: #selector(ViewTagClick))
        self.addGestureRecognizer(tap)
        //
          let imgV = UIImageView.init(image: UIImage(named: "icon_button_xuanzhong"))
         self.addSubview(imgV)
        //
        let  titleLab = UILabel.createLabWith(title: "搜索历史", titleColor: .Hex("#FF3B372B"), font: .pingfangSC(17))
        self.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(22)
        }
          //
        self.addSubview(delBut)
        delBut.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(22)
        }
        //
       
        imgV.snp.makeConstraints { (make) in
            make.centerX.equalTo(titleLab.snp.left)
            make.centerY.equalTo(titleLab.snp.bottom)
        }
        //
        
        self.addSubview(butsBgv)
        butsBgv.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(titleLab.snp.bottom).offset(20)
        }
        createRemenView(titles: self.titles)
        //
        let nodataImg = UIImageView.init(image: UIImage(named: "nodata"))
        self.addSubview(nodataImg)
        nodataImg.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(butsBgv.snp.bottom).offset(40)
        }
        //
        let title = "暂未找到“搜素记录”"
        let nodataTitle = UILabel.createLabWith(title: title, titleColor: .Hex("#FFD7D7D7"), font: .pingfangSC(21))
        self.addSubview(nodataTitle)
        nodataTitle.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(nodataImg.snp.bottom).offset(10)
        }
    }
//    lazy var delBut:UIButton = {
//
//        let but = UIButton.createButWith( image: #imageLiteral(resourceName: "delete")) {[weak self] (but) in
//
//        }
//        return but
//    }()
    lazy var butsBgv:UIView = {
        return UIView()
    }()
    func createRemenView(titles:[String]){
        let butsss = self.titleButs
        let  bg = butsBgv
        let leftRightMargin:CGFloat  = 15
        var x:CGFloat = leftRightMargin
        var y:CGFloat = 0
       
        let h :CGFloat = 30
        let w:CGFloat = 100
        let mrgin = (Configs.Dimensions.screenWidth - (w*3) - leftRightMargin*2) / 2
        let margin:CGFloat =  mrgin < 5 ? 10 : mrgin   //(Configs.Dimensions.screenWidth - 60 - w*3)/3
        for i in 0..<titles.count {
            var lab:UIButton!
            if butsss.count <= i {
                lab  = UIButton.createButWith(title: titles[i], titleColor: .Hex("#FF87827D"), font: .pingfangSC(15)) {[weak self] (but) in
                    if but.isSelected {
                        let tag = but.tag
                        but.removeFromSuperview()
                        self?.titleButs.remove(at: tag)
                        self?.titles.remove(at: tag)
                        self?.createRemenView(titles: self!.titles)
                        UserDefaults.standard.setValue(self!.titles, forKey: self!.useSaveKey)
                    }else{
                        if self?.didSelectedBlock != nil {
                            self!.didSelectedBlock!(but.currentTitle!)
                        }
                       
                    }
                  
               }
               lab.layer.cornerRadius = 15
               lab.layer.borderColor = mainYellowColor.cgColor
               lab.layer.borderWidth = 1
   //            lab.cornor(conorType: .allCorners, reduis: 15, borderWith: 1, borderColor: mainYellowColor)
               let imgv = UIImageView.init(image: #imageLiteral(resourceName: "delete-2"))
               imgv.tag = 101
               lab.addSubview(imgv)
               imgv.isHidden = true
               imgv.snp.makeConstraints { (make) in
                make.centerX.equalTo(lab.snp.right).offset(-6)
                make.centerY.equalTo(lab.snp.top).offset(5)
               }
   //            let lab = UILabel.createLabWith(title: titles[i], titleColor: .Hex("#FF87827D"), font: .pingfangSC(15), cornorRaduis: 15, cornorType: .allCorners, borderWith: 1, borderColor: mainYellowColor)
               let longtap = UILongPressGestureRecognizer.init(target: self, action: #selector(butLongTapClick(tap:)))
               lab.addGestureRecognizer(longtap)
                titleButs.append(lab)
            }else{
                lab = titleButs[i]
            }
            lab.setTitle(titles[i], for: .normal)
            lab.tag = i
            bg.addSubview(lab)
            lab.snp.remakeConstraints { (make) in
                make.left.equalToSuperview().offset(x)
                make.top.equalToSuperview().offset(y)
                make.size.equalTo(CGSize(width: w, height: h))
                if i == titles.count - 1 {
                    make.bottom.equalToSuperview().offset(-4)
                }
            }
            x += margin + w
            if x > Configs.Dimensions.screenWidth - leftRightMargin - w {
                x = leftRightMargin
                y += h + 15
            }
        }
    }
    lazy var delBut:UIButton = {
        let but = UIButton.createButWith( image: #imageLiteral(resourceName: "delete") ) {[weak self] (but) in
            self?.defualtAlert(title: "提示", message: "您确定要删除所有的搜索记录", sureBlock: { [weak self] (_) in
                UserDefaults.standard.removeObject(forKey: self!.useSaveKey)
                self?.titleButs.forEach { (but) in
                    but.removeFromSuperview()
                }
                self?.titleButs.removeAll()
                
            })
        }
        return but
    }()
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUI()
    }
    @objc func ViewTagClick(){
        titleButs.forEach { (but) in
            but.isSelected = false
            but.layer.removeAllAnimations()
            let imgv = but.viewWithTag(101)
            imgv?.isHidden  = true
        }
    }
    @objc func butLongTapClick(tap:UILongPressGestureRecognizer){
        titleButs.forEach { (but) in
            but.isSelected = true
            but.layer.add(myShakeAnimal, forKey: serachShakeAnimal)
            let imgv = but.viewWithTag(101)
            imgv?.isHidden  = false
        }
    }
    lazy var  myShakeAnimal:CABasicAnimation = {
      let anim = shakeAnimial()
        return anim
    }()
    func shakeAnimial()->CABasicAnimation{
        let animat = CABasicAnimation(keyPath: "transform.rotation.z")
        animat.fromValue = -0.1
        animat.toValue = 0.1
        animat.duration = 0.2
        animat.repeatCount = HUGE
        animat.autoreverses = true
        animat.isRemovedOnCompletion = false //切出此界面再回来动画不会停止
        return animat
    }
}
