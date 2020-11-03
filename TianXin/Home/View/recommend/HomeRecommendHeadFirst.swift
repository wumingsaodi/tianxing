//
//  HomeRecommendHeadFirst.swift
//  TianXin
//
//  Created by SDS on 2020/10/14.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import XRCarouselView
class HomeRecommendHeadFirst: UICollectionReusableView {
    static let headH:CGFloat = 170  //270 + 170
    let leftRightMargin:CGFloat = 10
    override init(frame: CGRect) {
        super.init(frame: frame)
        let  textV = UIView()
        textV.backgroundColor = .red
        createTitleButs()
    }
    func createTitleButs(){
        let leftBut = UIButton.createButWith( image: #imageLiteral(resourceName: "Game_sports")) {[weak self] (but) in
            self?.titleItemClick(inde: 0)
        }
        self.addSubview(leftBut)
      
        let rightbut  =  UIButton.createButWith( image: #imageLiteral(resourceName: "Game_caipiao")) {[weak self] (but) in
            self?.titleItemClick(inde: 5)
        }
        self.addSubview(rightbut)
        rightbut.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-leftRightMargin)
            make.top.equalToSuperview().offset(24.5)
            make.width.equalTo(scaleX(97))
//            make.size.equalTo(self.ScaleSize(img: rightbut.currentImage!))
        }
        leftBut.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftRightMargin)
            make.bottom.equalTo(rightbut)
            make.width.equalTo(scaleX(97))
//            make.size.equalTo(self.ScaleSize(img: leftBut.currentImage!))
        }
        let images:[UIImage] = [#imageLiteral(resourceName: "Game_dianjing"),#imageLiteral(resourceName: "Game_qipai"),#imageLiteral(resourceName: "Game_zhenren"),#imageLiteral(resourceName: "Game_buyu")]
            let but1  =  UIButton.createButWith( image: images[0]) {[weak self] (but) in
                self?.titleItemClick(inde: 1)
                
            }
            self.addSubview(but1)
        let but2  =  UIButton.createButWith( image: images[1]) {[weak self] (but) in
            self?.titleItemClick(inde: 2)
        }
        //
        self.addSubview(but2)
        let margin:CGFloat =  (Configs.Dimensions.screenWidth - scaleX( 97*2) - 8*2 - scaleX(75*2)) / 3
        let butw = scaleX(75)
        but2.snp.makeConstraints { (make) in
            make.left.equalTo(but1.snp.right).offset(margin)
            make.top.equalTo(rightbut).offset(-4)
            make.width.equalTo(butw)
//            make.size.equalTo(self.ScaleSize(img: leftBut.currentImage!))
        }
        but1.snp.makeConstraints { (make) in
            make.left.equalTo(leftBut.snp.right).offset(margin)
            make.bottom.equalTo(but2)
            make.width.equalTo(butw)
//            make.size.equalTo(self.ScaleSize(img: leftBut.currentImage!))
//                make.size.equalTo(CGSize(width: butw, height: buth))
        }

        //
        let but3  =  UIButton.createButWith( image: images[2]) {[weak self] (but) in
            self?.titleItemClick(inde: 3)
        }
        self.addSubview(but3)
        but3.snp.makeConstraints { (make) in
            make.left.equalTo(but1)
            make.bottom.equalTo(rightbut)
            make.width.equalTo(butw)
//            make.size.equalTo(self.ScaleSize(img: leftBut.currentImage!))
//                make.size.equalTo(CGSize(width: butw, height: buth))
        }
        let but4  =  UIButton.createButWith( image: images[3]) {[weak self] (but) in
            self?.titleItemClick(inde: 4)
        }
        self.addSubview(but4)
        but4.snp.makeConstraints {  (make) in
            make.left.equalTo(but2)
            make.bottom.equalTo(rightbut)
            make.width.equalTo(butw)
//            make.size.equalTo(CGSize(width: 30, height: 30))
//            make.size.equalTo(self.ScaleSize(img: leftBut.currentImage!))
//                make.size.equalTo(CGSize(width: butw, height: buth))
        }

                   
    
    }
    func ScaleSize(img:UIImage) -> CGSize {
        return CGSize(width: scaleX(img.size.width), height: scaleX(img.size.height))
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: - actions
extension HomeRecommendHeadFirst {
    func titleItemClick(inde:Int){
        
    }
}



class SDSBanar: XRCarouselView {
    static var share:XRCarouselView = SDSBanar().createBarnarView()
    func createBarnarView()->XRCarouselView{
        let banner = XRCarouselView()
        banner.placeholderImage = UIImage(named: "defualt")
        banner.setPageColor(.white, andCurrentPageColor: .red)
        banner.time = 1.5
        return banner
    }
}
