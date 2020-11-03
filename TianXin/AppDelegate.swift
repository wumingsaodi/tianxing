//
//  AppDelegate.swift
//  TianXin
//
//  Created by SDS on 2020/9/17.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Alamofire
#if DEBUG
import CocoaDebug
#endif

var sdsKeyWindow:UIWindow?{
    return UIApplication.shared.keyWindow
}
let kAppdelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
let LoginSuccessKey = "LoginSuccessKey"
let RegisterSuccessKey =  "RegisterSuccessKey"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
var window: UIWindow?
    /**
     横竖屏切换
     */
    var blockRotation:UIInterfaceOrientationMask = .portrait {
        didSet{
            if blockRotation.contains(.portrait) {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }else{
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            }
        }
    }
    
    var oldRootVC:UIViewController?

       func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool  {
        //
        UIView.awake()
        //
        IQKeyboardManager.shared.enable = true
//        checkVersion()
        
        #if DEBUG
        CocoaDebug.serverURL = Configs.Network.baseUrl
        #endif
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .white
        let vc =     MainTabBarVC() //CircleHomeSearchVC()
          window.makeKeyAndVisible()
        window.rootViewController = vc
        self.window = window
        //
        UINavigationBar.appearance().backIndicatorImage = R.image.back_white()
        UINavigationBar.appearance().tintColor = .darkGray
        confige()
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor.black
        ]
//        self.islogin()
        return true
    }
    
    func confige(){
        /**
         设置网络缓存
         */
        NetworkReachabilityManager.init()?.startListening(onUpdatePerforming: { (status) in
            if status == .unknown || status == .notReachable {
                SDSHUD.showError("网络不可用，请检查网络")
            }else if status == .reachable(.ethernetOrWiFi){
                //
            }
        })
//        if #available(iOS 13.0, *) {
        
        let tempStr = document.appendingPathComponent("url")
//        URLCache.init(memoryCapacity: <#T##Int#>, diskCapacity: <#T##Int#>, diskPath: <#T##String?#>)
        let urlCache = URLCache.init(memoryCapacity: 0, diskCapacity: 100*1024*1024, diskPath: tempStr)
            URLCache.shared = urlCache
//        } else {
//        }
       
        
        NetWorkingHelper.normalGetRequest(url: "https://cms.qiushengtiyu.com/api/advertis/1", params: [:], success: { (dict) in
            guard let model = BannerListModel.deserialize(from: dict)else {
                return
            }
            LocalUserInfo.share.setBanarList(model: model)
        }, fail: {_ in}, isBaseUrl: false)
    }
    func checkVersion(){
        let vm = HomeViewModel()
        vm.requistCheckUp(version: -1) {(isneedDown,url) in 
         //
        }
    }
  
    func islogin(isNeedLogin:Bool = true,isRootVC:Bool = false ,nav:UINavigationController? = nil)->Bool{
        if LocalUserInfo.share.islogin == false {
         
            if isNeedLogin {
                let loginVC = LoginVC()
                if isRootVC {
                    loginVC.isNotNeedNav = true
                    let rootvc = UIApplication.shared.keyWindow?.rootViewController
                    self.oldRootVC = rootvc
                    let nav = MainNavVC.init(rootViewController: loginVC)
                    nav.navigationBar.isHidden = true
                    UIApplication.shared.keyWindow?.rootViewController = nav
                             return false
                         }
                 
                if nav != nil {
                    nav?.pushViewController(loginVC,  animated: true)
                }else{
                    let navc  = getNavvc()
                     navc?.pushViewController(loginVC, animated: true)
                }
              
               
            }
            return false
        }
        return true
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
    
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
    
    }
    /**
     获取最顶的控制器
     */

    func getNavvc() -> UINavigationController? {
      let rootvc =   UIApplication.shared.keyWindow?.rootViewController
        let tabvc = rootvc as? MainTabBarVC
        let nav = tabvc?.selectedViewController
        return nav as? UINavigationController
    }
}

//MARK: - 横竖屏切换
extension AppDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return  blockRotation
    }
}
