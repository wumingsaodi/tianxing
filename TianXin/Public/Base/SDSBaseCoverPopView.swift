//
//  SDSBaseCoverPopView.swift
//  TianXin
//
//  Created by SDS on 2020/9/19.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class SDSBaseCoverPopView: UIView {
    
    
    private static var cover:UIView?
    private static var popView:SDSBaseCoverPopView?
    
    var isAllowMoreView:Bool = false
    private var subBgViews:[UIView] = [UIView]()
    /**
     需要重写的
     */
    func setsubBGView()->UIView{
        return UIView()
    }
    @objc  func cancel() {
        if isAllowMoreView {
                if subBgViews.count > 0 {
                    subBgViews.removeLast().removeFromSuperview()
                    
                    if subBgViews.count == 0 {
                        self.removeFromSuperview()
                    }else{
                        subBgViews.last!.isHidden = false
//                        self.addSubview(subBgViews.last!)
//                        subBgViews.last!.snp.makeConstraints { (make) in
//                            make.center.equalToSuperview()
//                            if(subBgViews.last!.sdsSize.width>0 && subBgViews.last!.sdsSize.height >
//                                0){
//                                make.size.equalTo(subBgViews.last!.sdsSize)
//                            }
//                        }
                    }
            } else{
                self.removeFromSuperview()
            }
        }else{
            self.removeFromSuperview()
        }
        
    }
    static   func ShowSDSCover(isAllowMoreView:Bool = false,istap:Bool = true)->SDSBaseCoverPopView{
        let popV = self.popView
        var view: SDSBaseCoverPopView
        if popV == nil {
            view = self.init()
            view.frame =  UIScreen.main.bounds
            self.popView = view
        }else{
            view = popV!
        }
        view.isAllowMoreView = isAllowMoreView
        
        if UIApplication.shared.keyWindow == nil {
            return view
        }
        UIApplication.shared.keyWindow?.addSubview(view)
        var cover  = SDSBaseCoverPopView.cover
        if cover == nil {
            cover = UIView()
            self.cover = cover
            cover!.backgroundColor = .init(white: 0, alpha: 0.3)
            view.addSubview(cover!)
        }
        if istap {
            let tap = UITapGestureRecognizer.init(target: view, action: #selector(cancel))
            cover!.addGestureRecognizer(tap)
        }
      
        
        
        
        cover!.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        let bgV = view.setsubBGView()
        if view.subviews.count > 1 {
            view.subviews.last?.isHidden = true
//            view.subviews.last?.removeFromSuperview()
        }
        if isAllowMoreView {
             view.subBgViews.append(bgV)
        }
        view.addSubview(bgV)
       
        bgV.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            if(bgV.sdsSize.width>0 && bgV.sdsSize.height >
                0){
                make.size.equalTo(bgV.sdsSize)
            }
        }
        return view
    }
    
}
