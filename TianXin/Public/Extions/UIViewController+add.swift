//
//  UIViewController+add.swift
//  TianXin
//
//  Created by SDS on 2020/9/21.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

extension UIView{
    func defualtAlert(title:String?,message:String?,sureBlock:((_ text:String?)->Void)?,textholder:String? = nil,cancel:String = "取消",sure:String = "确定")  {
        guard let  vc = self.getViewController()  else {
            return
        }
        let alertvc = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let cancleAC = UIAlertAction.init(title:cancel, style: .cancel, handler: nil)

        let sureAC = UIAlertAction.init(title: sure, style: .default) { (_) in
            if sureBlock != nil{
                if textholder != nil {
                    let text =   alertvc.textFields?.first?.text
                    sureBlock!(text)
                }else{
                    sureBlock!(nil)
                }
                
            }
        }
        alertvc
            .addAction(cancleAC)
        alertvc.addAction(sureAC)
        if textholder != nil {
            alertvc.addTextField { (textF) in
                textF.placeholder = textholder!
            }
        }
        vc.present(alertvc, animated: true, completion: nil)
    }
}

extension UIViewController {
    func defualtAlert(title:String?,message:String?,sureBlock:((_ text:String?)->Void)?,textholder:String? = nil,cancel:String = "取消",sure:String = "确定")  {
    self.view.defualtAlert(title: title, message: message, sureBlock: sureBlock, textholder: textholder, cancel: cancel, sure: sure)
    }
    static  func xib(_ vcName:String) -> UIViewController {
        let vc = UIViewController.init(nibName: vcName, bundle: nil)
        return vc
    }
    
    func setWhiteBackImg(imgName:String = "back_white",backTitle:String? = nil,backColor:UIColor? = .white,title:String? = nil,titleColor:UIColor? = .white ,hideNav:Bool = true) {
        self.setBackImg(imgName: imgName, backTitle: backTitle,backColor: backColor,title:title, titleColor: titleColor, hideNav: hideNav)
    }
    func  setBackImg(imgName:String = "back",backTitle:String? = nil,backColor:UIColor? = nil,title:String? = nil,titleColor:UIColor? = nil ,hideNav:Bool = false)  {
        if hideNav {
            self.navigationController?.navigationBar.isHidden = true
            let but = UIButton.createButWith( title: backTitle,titleColor: backColor,image: UIImage(named: imgName)) { [weak self] (_) in
                self?.navigationController?.navigationBar.isHidden = false
                self?.navigationController?.popViewController(animated: true)
            }
            but.setButType(type: .imgLeft, padding: 10)
            self.view.addSubview(but)
            but.snp.makeConstraints { (make) in
                make.left.equalToSuperview()
                make.top.equalToSuperview().offset(kStatueH)
                make.height.equalTo( 44)
                make.width.lessThanOrEqualTo(150)
                make.width.greaterThanOrEqualTo(50)
            }
            if title != nil {
                let lab = UILabel.createLabWith(title: title, titleColor: titleColor, font: .pingfangSC(19))
                self.view.addSubview(lab)
                lab.snp.makeConstraints { (make) in
                    make.centerX.equalToSuperview().offset(kStatueH)
                    make.top.equalToSuperview()
                    make.height.equalTo(44)
                }
            }
            return
        }
        let leftBut = UIButton.createButWith(title:backTitle,titleColor: backColor, image:UIImage(named: imgName)) { [weak self](_) in
            self?.navigationController?.popViewController(animated: true)
        }
        leftBut.setButType(type: .imgLeft, padding: 10)
        if leftBut.sdsW < 40 {
            leftBut.sdsW = 40
//            let but = leftBut as! SDSButton
//            let margin = 60 - but.sdsW
//            but.sdsW = 60
//            if but.currentTitle?.count ?? 0 <= 0 {
//                but.imageEdgeInsets = UIEdgeInsets(top: 0, left: -margin, bottom: 0, right: margin)
//            }
//            but.boundsPadding = UIEdgeInsets(top: 0, left: -margin, bottom: 0, right: margin)
            
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBut)
    }
}

protocol UIViewControllerFromStoryboard {
    static var storyboardName: String { get }
}
extension UIViewControllerFromStoryboard where Self: UIViewController {
    static var storyboardName: String {
        return "Main"
    }
}

extension UIViewController {
    
    func configureBackBarItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.back()?.withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(goBack(_:)))
    }
    
    @objc
    func goBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    static func instanceFrom(storyboard name: String) -> Self {
        return UIStoryboard(name: name, bundle: nil).instantiateViewController(withIdentifier: "\(self)") as! Self
    }
    
}

