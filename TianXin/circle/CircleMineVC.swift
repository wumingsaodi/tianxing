//
//  CircleMineVC.swift
//  TianXin
//
//  Created by SDS on 2020/10/5.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class CircleMineVC: SDSBaseVC {
    lazy var vm:CircleHomeViewModel = {
        return CircleHomeViewModel()
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(topTitlsV)
        
        topTitlsV.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(23)
        }
        self.view.addSubview(tableVCs)
        tableVCs.snp.makeConstraints { (make) in
            make.top.equalTo(topTitlsV.snp.bottom).offset(15)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    lazy var topTitlsV:SDSScrollTitlesView = {
        let titles = ["已关注","已点赞","已评论","已发布","已收藏"]
        let titlsv = SDSScrollTitlesView.init(ttles: titles, width: 61,height: 21, cell: minetopTitlCell.self) { [weak self](index, cell) in
            self?.tableVCs.scollToIndex(index: index)
        }
    
        return titlsv
    }()
    lazy var tableVCs:SDSScrollColltionView = {
        var vcs = [UIViewController]()
       
        for i in 0..<5 {
            var vc =   CircleRecomedTableVC()
            vc.tableViewScrollToTopOrBottom = self.tableViewScrollToTopOrBottom
            if i == 0 {//已关注
                vc.requistBlock = {[weak self](currpage,success) in
                    self!.vm.requistMyCareList(currPage: currpage, success: success)
                }
                vc.isDeleAfterCancleAttion = true
                vcs.append(vc)
            } else if i == 1 {//已点赞
                vc.requistBlock = {[weak self](currpage,success) in
                    self!.vm.requistMyLikeList(currPage: currpage, success: success)
                }
                vc.isDeleteAfterCancleLive = true
                vcs.append(vc)
            }else if i == 2 {//已评论
                let remark =   CircleHomeMyRemarkVC()
                remark.tableViewScrollToTopOrBottom = self.tableViewScrollToTopOrBottom
                vcs.append(remark)
                
            }else if i == 3 {//已发布
                vc.isMyIssue = true
                vc.requistBlock = {[weak self](currpage,success) in
                    self!.vm.requistMyIssueList(currPage: currpage, success: success)
                }
                vcs.append(vc)
            } else if i == 4 {//已收藏
                vc.requistBlock = {[weak self](currpage,success) in
                    self!.vm.requistMyCollectList(currPage: currpage, success: success)
                }
                vcs.append(vc)
            }
           
        }
        
        let colletionv = SDSScrollColltionView.init(VCs: vcs) {[weak self] (index) in
            self?.topTitlsV.scollToIndex(index: index)
        }
        return colletionv
    }()
    
}


class minetopTitlCell: titleCollectCell {
    override func setContentView() {
        self.addSubview(titleL)
        //        titleL.snp.makeConstraints { (make) in
        //            make.edges.equalToSuperview()
        //        }
        titleL.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 61, height: 21))
        }
    }
    override func settitle(title:String){
        titleL.text = title
    }
    override func normalStatue() {
        titleL.backgroundColor = .Hex("#e7e7e7")
        titleL.textColor = .Hex("#999998")
    }
    override func didSelectedStatue() {
        titleL.textColor = mainYellowColor
        titleL.backgroundColor = .Hex("#f9d7ab")
    }
    lazy var titleL:UILabel = {
        let lab = UILabel.createLabWith(title: "", titleColor: .Hex("#999998"), font: .pingfangSC(12),aligment:.center)
        lab.backgroundColor = .Hex("#e7e7e7")
        lab.cornor(conorType: .allCorners, reduis: 10.5)
        return lab
    }()
}
