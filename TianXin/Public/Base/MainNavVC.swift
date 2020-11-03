//
//  MainNavVC.swift
//  TianXin
//
//  Created by SDS on 2020/9/18.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class MainNavVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barTintColor = .white

    }
    func setBackGroundImg(backImg:UIImage){
        self.navigationBar.setBackgroundImage(backImg, for: .default)
    }
    func setBackgroudColor(color:UIColor){
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.tintColor = color
    }
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
           if self.children.count == 1 {
               viewController.hidesBottomBarWhenPushed = true
           }
           super.pushViewController(viewController, animated: animated)
       }
}

extension UINavigationController {
    func pushViewController(_ viewController:UIViewController,isNeedLogin:Bool,animated: Bool) {
        if isNeedLogin {
            if  kAppdelegate.islogin() == false {
                return
            }
            self.pushViewController(viewController, animated: animated)
        }
    }
}
