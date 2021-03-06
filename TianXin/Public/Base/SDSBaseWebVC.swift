//
//  SDSBaseWebVC.swift
//  TianXin
//
//  Created by SDS on 2020/9/18.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class SDSBaseWebVC: UIViewController {
    var url:String = ""{
        didSet{
            guard let url = URL(string: self.url) else {
                return
            }
         webView.load(URLRequest(url: url))
        }
    }
    var isHaveNav:Bool = true
    var isShowProgross:Bool = true
  lazy  var webView:SDSBaseWebView = {
        let web  = SDSBaseWebView.createWebView(isShowPragross:self.isShowProgross)
        return web
    }()
    convenience    init(url:String,isHaveNav:Bool = true,isShowProgross:Bool = true,isNeeedLogin:Bool = false){
        self.init()
        self.url = url
        self.isHaveNav = isHaveNav
        if isNeeedLogin {
//            LocalUserInfo.share.getLoginInfo {[weak self] (model) in
//                if model == nil {//退出登陆了
////                    self?.setLogin()
//                }
//            }
        }
    }
    func setLogin(){
        let vc = LoginVC()
        self.view.addSubview(vc.view)
        vc.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        SetUI()
        guard let url = URL(string: self.url) else {
//            SDSHUD.showError("")
            return
        }
        webView.load(URLRequest(url: url))
//        setJSUseOcMethonds()
    }
    func SetUI(){
        self.view.addSubview(webView)
       
            webView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview().offset(-kBottomSafeH)
                 if self.isHaveNav {
                    make.top.equalToSuperview().offset(KnavHeight)
                }else{
                    make.top.equalToSuperview()
                }
        }
    }
    
    func setJSUseOcMethonds() {
       // webView.addJSUseOCMethod(name: <#T##String#>, block: <#T##(([String : Any]) -> Void)##(([String : Any]) -> Void)##([String : Any]) -> Void#>)
    }
}
