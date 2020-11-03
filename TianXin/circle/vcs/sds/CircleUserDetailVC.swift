//
//  CircleUserDetailVC.swift
//  TianXin
//
//  Created by SDS on 2020/10/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class CircleUserDetailVC: SDSBaseVC {
    
    
    lazy var vm = {
        return  CircleDetailViewModel()
    }()
    var recommendId:String = ""
    var maxOffsetY:CGFloat = 225 - kStatueH - 10
    convenience init(recommendId:String) {
        self.init()
        self.recommendId = recommendId
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        setUI()
        
        FloatingButton.default.show(in: self.view) { [ weak self] in
            guard let self = self else { return }
            if self.vm.infoModel?.isJoin ?? false == false {
                SDSHUD.showError("你尚未加入这个圈子")
                return
            }
            if LocalUserInfo.share.userInfo?.nickName.isEmpty ?? true {
                // 未设置昵称，提醒用户设置昵称
                SDSHUD.showError("请前往个人中心设置昵称")
                return
            }
            let vc = PostingViewController.`init`(viewModel: .init(fromType: .圈子(circleId: self.recommendId)))
            self.navigationController?.pushViewController(vc, isNeedLogin: true, animated: true)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setWhiteBackImg( backTitle: nil)
    }
    lazy  var bgscrollv:UIScrollView = {
        let bgscrollv = UIScrollView()
        return bgscrollv
    }()
    
    func setUI(){
        self.view.addSubview(bgscrollv)
        bgscrollv.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()//.offset(-kBottomSafeH)
            make.top.equalToSuperview().offset(kStatueH)
        }
        bgscrollv.contentLayoutGuide.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(225 - kBottomSafeH - kStatueH)
        }
        //
        bgscrollv.addSubview(head)
        head.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(225)
        }
        //
        bgscrollv.addSubview(titlesv)
        titlesv.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview()
            make.top.equalTo(head.snp.bottom).offset(3)
            make.height.equalTo(30)
        }
        //
        bgscrollv.addSubview(scrolleVCs)
        scrolleVCs.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(titlesv.snp.bottom).offset(3)
        }
    }
    lazy var head:CircleDetailHead = {
        let head = UIView.xib(xibName: "CircleDetailHead") as! CircleDetailHead
        return head
    }()
    lazy var titlesv:SDSScrollTitlesView = {
        let titles = ["全部","精华"]
        let titlesv = SDSScrollTitlesView.init(ttles: titles, width: 50) {[weak self] (index, cell) in
            self?.scrolleVCs.scollToIndex(index: index)
        }
        return titlesv
    }()
    lazy var scrolleVCs:SDSScrollColltionView = {
        var vcs = [UIViewController]()
        for i in 0..<2 {
            let vc = CircleUserDetailtableVC()
                        vc.tableViewScrollToTopOrBottom = { [weak self](isTop,offsety) in
                            NJLog("\(offsety)")
                            let offset = self!.bgscrollv.contentOffset
                            if isTop {
                                self?.bgscrollv.contentOffset =  CGPoint(x: offset.x, y: offset.y + offsety)
                                if offset.y <= 0 {
                                    self?.bgscrollv.contentOffset =  CGPoint(x: offset.x, y: 0)
                                    return true
                                }
            return  false
            //                    self?.bgscrollv.setContentOffset(CGPoint(x: offset.x, y:offset.y + offsety ), animated: false)
                            }else{
            
                                self?.bgscrollv.contentOffset =  CGPoint(x: offset.x, y: offset.y + offsety)
                                if offset.y >= self!.maxOffsetY {
                                    self?.bgscrollv.contentOffset =  CGPoint(x: offset.x, y: self!.maxOffsetY)
                                    return true
                                }
                                if offset.y < 0 {
                                    self?.bgscrollv.contentOffset =  CGPoint(x: offset.x, y: 0)
                                }
            //                    self?.bgscrollv.setContentOffset(CGPoint(x: offset.x, y: offset.y + offsety), animated: true)
                            }
                        return false
                        }
            if i == 0 {
                vc.requistBlock = {[weak self](currpage,success) in
                    self?.vm.requistAllIssueList(recommendId: self!.recommendId, currPage: currpage, success: success)
                }
                vc.setHedBlock = { [weak self] in
                    if let model = self!.vm.infoModel{
                        self?.head.refreshUI(model:model)
                        
                    }
                }
            }else{
                vc.requistBlock = {[weak self](currpage,success) in
                    self?.vm.requistcircleIssueEssenceList(recommendId: self!.recommendId, currPage: currpage, success: success)
                }
            }
            vcs.append(vc)
        }
        let scrollv = SDSScrollColltionView.init(VCs: vcs) { [weak self](index) in
            self!.titlesv.scollToIndex(index: index)
        }
        return scrollv
    }()
    
}
