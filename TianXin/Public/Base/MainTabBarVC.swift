//
//  MainTabBarVC.swift
//  TianXin
//
//  Created by SDS on 2020/9/18.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class MainTabBarVC: UITabBarController {
    var gameVc:SDSBaseWebVC?
    override func viewDidLoad() {
        self.delegate = self
        self.tabBar.barTintColor = .white
        self.tabBar.tintColor = .init(red: 1, green: 0.77, blue: 0.4, alpha: 1)
          addSubVCS()
        // 去掉顶部线条
        self.tabBar.shadowImage = UIImage()
        if #available(iOS 13, *) {
            let appearance = self.tabBar.standardAppearance.copy()
            appearance.backgroundImage = try? UIImage(color: .white)
            appearance.shadowImage = try? UIImage(color: .init(white: 0.95, alpha: 0.4))
            appearance.shadowColor = .clear
            self.tabBar.standardAppearance = appearance
        } else {
            self.tabBar.shadowImage = UIImage()
            self.tabBar.backgroundImage = try? UIImage(color: .white)
        }

        super.viewDidLoad()
        NetWorkingHelper.normalPost(url: "/gl/user/getAppHome", params: [:]) { [weak self](dict) in
            guard let url = dict["data"] as? String else{
                return
            }
            LocalUserInfo.share.getLoginInfo { (model) in
                
            }
            let gameUrl  = url + "?token=" + (LocalUserInfo.share.sessionId  ?? "")
            self?.gameVc?.url = gameUrl
        }
            }
    func addSubVCS(){
        let homeVC = HomeVC()
        setUPChildVC(title: "首页", img: "tab_home", selectedImg: "tab_home_selected", child: homeVC)
        let guangchangvc = CircleHomeVC()
             setUPChildVC(title: "广场", img:"tab_guangchang" , selectedImg: "tab_guangchang_selected", child: guangchangvc)
     
        let webVc = SDSBaseWebVC.init(url: "")
        gameVc = webVc
         setUPChildVC(title: "游戏", img: "kok", selectedImg: "kok", child: webVc,TopPadding: 10)
//            kAppdelegate.getNavvc()?.pushViewController(webVc, animated: true)
//        let gameVC =   //GameVC()
//        setUPChildVC(title: "游戏", img: "kok", selectedImg: "kok", child: gameVC,TopPadding: 10)
//        let keFuVC = KefuVC()
//             setUPChildVC(title: "客服", img: "tab_kefu", selectedImg: "tab_kefu_selected", child: keFuVC)
        let topicVC = TopicViewController.instance
             setUPChildVC(title: "专题", img: "icon_zhuanti1", selectedImg: "icon_zhuanti2", child: topicVC)
        let mineVC = MineVC()
             setUPChildVC(title: "我的", img: "tab_mine", selectedImg: "tab_mine_selected", child: mineVC)
        
    }
    func setUPChildVC(title:String,img:String,selectedImg:String,child:UIViewController,TopPadding:CGFloat? = nil){
        child.tabBarItem.title = title
        let  unselecteimg =  UIImage(named: img)?.withRenderingMode(.alwaysOriginal)
       
        child.tabBarItem.image = unselecteimg
        child.tabBarItem.selectedImage = UIImage(named: selectedImg)?.withRenderingMode(.alwaysOriginal)
        child.title = title
       
        if TopPadding != nil {
            child.tabBarItem.imageInsets = UIEdgeInsets(top: -TopPadding!, left: 0, bottom: TopPadding!, right: 0)
        }
        let nav = MainNavVC.init(rootViewController: child)
        addChild(nav)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        #if DEBUG
        UIDebug.shared.enable()
        #endif
    }
}

extension MainTabBarVC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if (viewController as? UINavigationController)?.viewControllers[0] is GameVC {
            presentKOK()
            return false
        }
        return true
    }
}
