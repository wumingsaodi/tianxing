//
//  CircleHomeMyRemarkVC.swift
//  TianXin
//
//  Created by SDS on 2020/10/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class CircleHomeMyRemarkVC: UIViewController {
    var tableViewScrollToTopOrBottom:((_ isTop:Bool, _ offsetY:CGFloat)-> Bool)?
    var currPage:Int = 1
    lazy var vm:CircleHomeViewModel = {
      return CircleHomeViewModel()
    }()
    var modes:[RemarkModel] = [RemarkModel]()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        requistData()
    }
    lazy var tableView:SDSTableView = {
        let tab = SDSTableView.CreateTableView().sdsNumOfRows(block: {[weak self] (section) -> Int in
            return self!.modes.count
        }).sdsRegisterCell(cellClass: "CircleHomeRemarkCell",isNib: true, cellBlock: { [weak self] (indexPath, cell) in
            let ncell = cell as! CircleHomeRemarkCell
            let model = self!.modes[indexPath.row]
            ncell.delBlock = { [weak self] in
                self?.vm.reuestDelMyRemark(remarkId: String(model.remarkId), success: {[weak self] in
                    self?.modes.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                })
            }
//            ncell.AttentionClickBlock = {[weak self](isAttetion) in
//                        if isAttetion {//取消点赞
//                            NetWorkingHelper.normalPost(url: Configs.Network.Square.delUserILike , params: ["likeType":"1","nickName":model.showName,"remarkId":model.remarkId]) { [weak  self] (dict) in
//                                self?.requistData()
//                            }
//                        }else{//点赞
//
//                            NetWorkingHelper.normalPost(url: Configs.Network.Square.addUserLike, params: ["likeType":"1","nickName":model.showName,"remarkId":model.remarkId]) { [weak self] (dict) in
//                                self?.requistData()
//                            }
//                        }
//            }
            ncell.setModel(model:model )
        }, height: { (_) -> CGFloat in
            return 180
        }).sdsDidSelectCell {[weak self] (indexPath) in
            let model = self!.modes[indexPath.row]
            let vc = IssueDetailViewController.`init`(withIssueId: "\(model.issueId)")
            self?.navigationController?.pushViewController(vc, isNeedLogin: true, animated: true)
        }.sdsMJRerechBlock {[weak self] (isHead) in
            if isHead {
                self!.currPage = 1
            }
            self?.requistData()
        }
        tab.tableViewScrollToTopOrBottom = self.tableViewScrollToTopOrBottom
        return  tab
    }()

    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.currPage = 1
        requistData()
    }
}

//MARK: - actions
extension CircleHomeMyRemarkVC {
    func requistData(){
        vm.requistMyRemarkList(currPage: self.currPage) { (models, isNomore) in
            if self.currPage == 1 {
                self.modes = models
            }else{
                self.modes.append(contentsOf: models)
            }
            self.currPage += 1
            self.tableView.reloadData()
        }
    }
}
