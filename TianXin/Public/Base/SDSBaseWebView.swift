//
//  SDSBaseWebView.swift
//  TianXin
//
//  Created by SDS on 2020/9/18.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import WebKit
class SDSBaseWebView: WKWebView {
    var isAllowScale:Bool = false
    lazy  var progressView:UIProgressView = {
        let progress = UIProgressView()
        progress.progressTintColor = .red
        return progress
    }()
    static func createWebView(isShowPragross:Bool = true) ->SDSBaseWebView{
        let config = WKWebViewConfiguration()
        //以下代码适配文本大小，由UIWebView换为WKWebView后，会发现字体小了很多，这应该是WKWebView与html的兼容问题，解决办法是修改原网页，要么我们手动注入JS
        let jSString = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width scale = 1.0'); document.getElementsByTagName('head')[0].appendChild(meta);";
        //用于进行JavaScript注入
        let  userController = WKUserContentController()
        let script  = WKUserScript.init(source: jSString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userController.addUserScript(script)
        config.userContentController = userController
        
        let web = SDSBaseWebView.init(frame: .zero, configuration: config)
        web.uiDelegate = web
        web.navigationDelegate = web
        //显示进度条
        if isShowPragross {
               web.addSubview(web.progressView)
            web.progressView.snp.makeConstraints { (make) in
                     make.left.right.equalToSuperview()
                     make.top.equalToSuperview().offset(1)
//                     make.height.equalTo(2)
                 }
            web.addObserver(web, forKeyPath: "estimatedProgress", options: .new, context: nil)
    
         
     
        }
        //title
        web.addObserver(web, forKeyPath: "title", options: .new, context: nil)
        return web
        
    }
    var nameAndBlockDicts:[String:(([String:Any])->Void)] = [String:(([String:Any])->Void)]()
    func addJSUseOCMethod(name:String,block:@escaping ((_ dict:[String:Any])->Void)){
        if nameAndBlockDicts.keys.contains(name){
            return
        }
        nameAndBlockDicts.updateValue(block, forKey: name)
        self.configuration.userContentController.add(self, name: name)
    }
    /**
     oc 调用js方法
     */
    func swiftUseJSMethod(name:String,block:@escaping (Any?,Error?)->Void){
        self.evaluateJavaScript(name) { (respone, error) in
            block(respone,error)
        }
    }
    
}
extension SDSBaseWebView:WKScriptMessageHandler{
    /**
     js调用oc方法
     */
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let messageName = message.name
        let params = message.body as? [String:Any] ?? [:]
        for key in nameAndBlockDicts.keys {
            if key == messageName {
                let block = nameAndBlockDicts[key]
                block!(params)
                break
            }
        }
    }
}
//MARK: - WKNavigationDelegate delegate
extension SDSBaseWebView:WKNavigationDelegate{
    // 根据WebView对于即将跳转的HTTP请求头信息和相关信息来决定是否跳转
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        //        if -1 {
        //            decisionHandler(.cancel)
        //        }else{
        decisionHandler(.allow)
        //        }
        
    }
}
//MARK: -禁止缩放手势
extension SDSBaseWebView:UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if !self.isAllowScale{
            return nil
        }
        return self
    }
}
//MARK: - WKUIDelegate delegate
extension SDSBaseWebView:WKUIDelegate{

    /**
     alert 弹框
     */
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        if let parentVC  = self.getViewController(){
            let alertVC = UIAlertController.init(title: "提示", message: message, preferredStyle: .alert)
            let  sureAC = UIAlertAction.init(title: "确定", style: .default) { (_) in
                completionHandler()
                //                alertVC.dismiss(animated: true, completion: nil)
            }
//            let cancelAC = UIAlertAction.init(title: "取消", style: .cancel) { (_) in
//                           completionHandler()
//                       }
//            alertVC.addAction(cancelAC)
            alertVC.addAction(sureAC)
            parentVC.present(alertVC, animated: true, completion: nil)
        }
    }
    /**
     确认框处理
     */
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        if let parentVC  = self.getViewController(){
            let alertVC = UIAlertController.init(title: "提示", message: message, preferredStyle: .alert)
            let  sureAC = UIAlertAction.init(title: "确定", style: .default) { (_) in
                completionHandler(true)
                //                alertVC.dismiss(animated: true, completion: nil)
            }
            let cancelAC = UIAlertAction.init(title: "取消", style: .cancel) { _
                in
                completionHandler(false)
            }
            alertVC.addAction(cancelAC)
            alertVC.addAction(sureAC)
            parentVC.present(alertVC, animated: true, completion: nil)
        }
    }
    /**
     输入框处理
     */
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        if let parentVC  = self.getViewController(){
            let alertVC = UIAlertController.init(title: prompt, message: "", preferredStyle: .alert)
            alertVC.addTextField { (tf) in
                tf.text = defaultText
            }
            let  sureAC = UIAlertAction.init(title: "确定", style: .default) { (_) in
                completionHandler(alertVC.textFields?.first?.text)
            }
            let cancelAC = UIAlertAction.init(title: "取消", style: .cancel) { _ in
                
                
            }
            alertVC.addAction(cancelAC)
            alertVC.addAction(sureAC)
            parentVC.present(alertVC, animated: true, completion: nil)
        }
    }
    // 页面是弹出窗口 _blank 处理
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame!.isMainFrame {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
}
//MARK: -   观察者监听
extension SDSBaseWebView {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        NJLog("keyPath\(keyPath!)")
        if keyPath! == "estimatedProgress" {
  
            self.progressView.progress = Float(self.estimatedProgress)
            if self.estimatedProgress >= 1 {
                self.progressView.progress = 0
            }
        } else if keyPath! == "title" {
            self.getViewController()?.title = self.title
        }else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
