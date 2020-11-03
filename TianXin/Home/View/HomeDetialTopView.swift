//
//  HomeDetialTopView.swift
//  TianXin
//
//  Created by SDS on 2020/9/25.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class HomeDetialTopView: UIView {
    static let headerH:CGFloat = 130
    let leftRightMargin:CGFloat = 10
    var labtitles:[String]?{
        didSet{
            createLab()
        }
    }
    init(titles:[String]) {
        super.init(frame: .zero)
         self.labtitles = titles
        createLab()
        setUI()
       
    }
    func setUI(){
        //
//        self.addSubview(firstAdImgv)
//
//        firstAdImgv.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(leftRightMargin)
//            make.right.equalToSuperview().offset(-leftRightMargin)
//            make.top.equalToSuperview()
//            make.height.equalTo(78)
//        }
        //
        self.addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(firstAdImgv.snp.bottom).offset(10)
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(leftRightMargin)
            make.right.equalToSuperview().offset(-leftRightMargin)
        }
        //
        self.addSubview(timeL)
        timeL.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(leftRightMargin)
            make.top.equalTo(textLabel.snp.bottom).offset(5)
        }
        //
//        self.addSubview(visitedTiemsL)
//        visitedTiemsL.snp.makeConstraints { (make) in
//            make.right.equalToSuperview().offset(-leftRightMargin)
//            make.centerY.equalTo(timeL)
//        }
//        //
//        let visitedimgV = UIImageView(image: UIImage(named: "liulanliang"))
//        self.addSubview(visitedimgV)
//        visitedimgV.snp.makeConstraints { (make) in
//            make.right.equalTo(visitedTiemsL.snp.left).offset(-5)
//            make.centerY.equalTo(visitedTiemsL)
////            make.size.equalTo(CGSize(width: 16, height: 16))
//        }
        //
        self.addSubview(titlesBG)
        titlesBG.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(timeL.snp.bottom).offset(8)
        }
        //
//        self.addSubview(adSportImgv)
//        adSportImgv.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(10)
//            make.right.equalToSuperview().offset(-10)
//            make.top.equalTo(titlesBG.snp.bottom).offset(5)
//            make.height.equalTo(200)
//        }
    }
    func  createLab(){
        for view in titlesBG.subviews {
            view.removeFromSuperview()
        }
        if let titles = labtitles {
            
            var perView:UIView = titlesBG
            
            for i in 0..<titles.count {
                let lab = UILabel.createLabWith(title: titles[i], titleColor:.Hex("#FF7D7B81"), font: .pingfangSC(13), padding: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
                lab.backgroundColor = .Hex("#FFF0EFF4")
                lab.cornor(conorType: .allCorners, reduis: 4)
                titlesBG.addSubview(lab)
                lab.snp.makeConstraints { (make) in
                    if i == 0 {
                        make.left.equalToSuperview().offset(leftRightMargin)
                        make.bottom.equalToSuperview()
                    }else{
                        make.left.equalTo(perView.snp.right).offset(5)
                    }
                    make.top.equalToSuperview()
                }
                perView = lab
            }
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy  var titlesBG:UIView = {
        return UIView()
    }()
//    lazy var adSportImgv:UIImageView = {
//        let imagev = UIImageView.init(image: UIImage(named: "Advertising_sport"))
//        imagev.contentMode = .scaleAspectFit
//        return imagev
//    }()
//    lazy var visitedTiemsL:UILabel = {
//        let lab = UILabel.createLabWith(title: "0", titleColor: .Hex("#FF9E9E9E"), font: .pingfangSC(13))
//        return lab
//    }()
//    lazy var firstAdImgv:UIImageView = {
//        let adImgV = UIImageView(image: UIImage(named: "Advertising"))
//        return adImgV
//    }()
    lazy var textLabel:UILabel = {
        let lab =  UILabel.createLabWith(title: "我心爱的妹妹被迫嫁给不爱他的男人", titleColor: .Hex("#FF3B372B"),  font: .pingfangSC(17))

        lab.numberOfLines = 0
        return lab
    }()
    lazy var timeL:UILabel = {
        let lab = UILabel.createLabWith(title: "2020-00-00  00:00:00/32.4万次播放", titleColor: .Hex("#FF9E9E9E"), font: .pingfangSC(13))
        return lab
    }()
    func  setHeadModel(model:HomeMovieItem){
        self.labtitles = model.keywords
        let  historyStr = model.historyNum > 10000 ? String(format: "%0.1f万次播放", Float(model.historyNum) / 10000 )  : "\(model.historyNum)次播放"
        self.timeL.text = model.time + "/" + historyStr
        textLabel.text = model.name
    }
}
