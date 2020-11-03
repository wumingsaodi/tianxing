//
//  HometopSearchView.swift
//  TianXin
//
//  Created by SDS on 2020/9/21.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class HometopSearchView: UIView {
  lazy  var leftBut:UIButton = {
    let but = UIButton.createButWith( image: UIImage(named: "logo_1"), sel: {[weak self](_)  in
        let vc = KOKHomeViewController.instanceFrom(storyboard: "Kok")
        let fromVc = self?.viewController()
        fromVc?.show(vc, sender: fromVc)
    })
//    but.isUserInteractionEnabled = false
    return but
    }()
    lazy var centerBut:UIButton = {
        let but = UIButton.createButWith(title: "请输入你想查找的关键字", titleColor: .Hex("#87827D"), font: .pingfangSC(13), image: UIImage(named: "seach"),  backGroudColor: .Hex("#F7F8FC")) {[weak self]  (_)in
            let parentVc = self!.getViewController()
            let searchVC = HomeSearchVC()
//            searchVC.hidesBottomBarWhenPushed = true
            //SearchViewController.instanceFrom(storyboard: "Search")
            parentVc?.navigationController?.pushViewController(searchVC, animated: true)
        }
        but.cornor(conorType: .allCorners, reduis: 14.25)
        return but
    }()
    lazy var letfFirst:UIButton = {
        let but = UIButton.createButWith(image: UIImage(named: "icon_classification"),  backGroudColor: .Hex("#F7F8FC")) {[weak self] (_) in
//            let  homeMoreVc = HomeMoreVC()
//            self!.getViewController()?.navigationController?.pushViewController(homeMoreVc, animated: true)
            guard let self = self else { return }
            self.presentHomeMenu().bindViewModel(self.menus)
            
             }
        return but
    }()
    
    var menus: [typeItmeModel] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI(){
        self.addSubview(letfFirst)
            letfFirst.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().offset(10)
                  make.size.equalTo(CGSize(width: 29, height: 29))
            }
        //
        self.addSubview(leftBut)
        leftBut.snp.makeConstraints { (make) in
            make.left.equalTo(letfFirst.snp.right).offset(10)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 29, height: 29))
        }
        //
        self.addSubview(centerBut)
        centerBut.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.left.equalTo(leftBut.snp.right).offset(10)
//            make.width.equalTo(269.5)
            make.height.equalTo(29)
        }
        //
    
    }
}
