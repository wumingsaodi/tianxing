//
//  SDSBaseVC.swift
//  TianXin
//
//  Created by SDS on 2020/9/21.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class SDSBaseVC: UIViewController {
    var tableViewScrollToTopOrBottom:((_ isTop:Bool, _ offsetY:CGFloat)-> Bool)?
    override func viewDidLoad() {
        super.viewDidLoad()
//        let  tap = UITapGestureRecognizer.init(target: self, action: #selector(hidekeyBord))
//        tap.delegate = self
//        self.view.addGestureRecognizer(tap)
        
        
        self.view.backgroundColor = baseVCBackGroudColor_grayWhite
        self.setBackImg()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
  @objc  func hidekeyBord() {
    NJLog("SDSBaseVC--tap")
    self.view.endEditing(true)
    self.view.resignFirstResponder()
    }

}
//extension SDSBaseVC:UIGestureRecognizerDelegate {
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//            if (gestureRecognizer.view?.isKind(of: UITableView.self))! ||   ((gestureRecognizer.view?.isKind(of: UICollectionView.self)) != nil) {
//                return false
//            }
//            return true
//        }
//    }
   

