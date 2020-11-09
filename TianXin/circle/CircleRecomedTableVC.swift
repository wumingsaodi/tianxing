//
//  CircleRecomedTableVC.swift
//  TianXin
//
//  Created by SDS on 2020/10/2.
//  Copyright © 2020 SDS. All rights reserved.
//
//enum tableCellTape {
//    case <#case#>
//}
import UIKit
import MJRefresh
class CircleRecomedTableVC: UIViewController {
    var orginY:CGFloat = .zero
    //取消点赞之后是否删除
    var isDeleteAfterCancleLive:Bool = false
    //取消关注后是否删除
    var isDeleAfterCancleAttion:Bool = false
    var tableViewScrollToTopOrBottom:((_ isTop:Bool, _ offsetY:CGFloat)-> Bool)?
    let beiginPage:Int = 1
    var currPage:Int = 1
    //    var isRefreshed: Bool = false
    var requistBlock:((_ currPage: Int, _ success:@escaping ((_ models:[CircleHomeModel],_ isNoMore:Bool)->Void))->Void)?
    /**
     是不是我的发布
     */
    var isMyIssue:Bool = false
    lazy var vm:CircleHomeViewModel = {
        return  CircleHomeViewModel()
    }()
    var models:[CircleHomeModel] = [CircleHomeModel](){
        didSet{
            if models.count > 0 {
                tableView.noDataView.isHidden = true
            }else{
                tableView.noDataView .isHidden = false
            }
        }
    }
    
    var isNoMore:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        requistDataList()
        
    }
    lazy var tableView:SDSTableView =  {
        let tab = SDSTableView.CreateTableView()
        tab.delegate = self
        tab.dataSource = self
        
        tab.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {[weak self] in
            self!.currPage = self!.beiginPage
            self?.requistDataList()
            
        })
        tab.mj_header?.ignoredScrollViewContentInsetTop = 10
        tab.mj_footer = MJRefreshFooter.init(refreshingBlock: {[weak self] in
            if self!.isNoMore{
                tab.mj_footer?.endRefreshing()
                return
            }
            self!.requistDataList()
        })
        tab.mj_footer?.isUserInteractionEnabled = false
        //        tab.sendSubviewToBack(tab.mj_footer!)
        if isMyIssue{
            tab.register(CircleHomeMyIssueCell.self, forCellReuseIdentifier: CircleHomeMyIssueCell.className())
        }else{
            tab.register(CircleRecomedTableCell.self, forCellReuseIdentifier: CircleRecomedTableCell.className())
        }
        
        tab.estimatedRowHeight = 200
        return tab
    }()
//MARK: - viewwillApper
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.currPage = beiginPage
        requistDataList()
    }
    //    lazy var tableView:SDSTableView = {
    //
    //
    //
    ////        let tab =  SDSTableView.CreateTableView().sdsNumOfRows(block: {[weak self] (_) -> Int in
    ////            return self!.models.count
    ////        }).sdsRegisterCell(cellClass: CircleRecomedTableCell.className(), cellBlock: {[weak self] (indexPath, cell) in
    ////            let ncell = cell as! CircleRecomedTableCell
    ////            ncell.setModel(model: (self?.models[indexPath.row])!)
    ////
    ////        }, height: { (indexPath) -> CGFloat in
    ////            let height =  CircleRecomedTableCell.hyb_cellHeight(forTableView: self.tableView) {[weak self] (cell) in
    ////                let ncell = cell as! CircleRecomedTableCell
    ////                ncell.setModel(model: self!.models[indexPath.row])
    ////            } updateCacheIfNeeded: { () -> (key: String, stateKey: String, shouldUpdate: Bool) in
    ////                return ("CircleRecomedTableVC","CircleRecomedTableCell",self.isRefreshed)
    ////            }
    ////            return  height
    ////
    ////        }).sdsDidSelectCell { (indexPath) in
    ////
    ////        }
    ////        tab.getCellHeightWith(identifier: <#T##String#>, Config: <#T##(T) -> Void#>)
    //        return tab
    //    }()
}


extension CircleRecomedTableVC:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return  100
    //    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //删除评论
        if isMyIssue {
            let cell = tableView.dequeueReusableCell(withIdentifier: CircleHomeMyIssueCell.className()) as! CircleHomeMyIssueCell
            cell.setModel(model: models[indexPath.row])
            cell.IssueDelBlock = {[weak self](issueId) in
                NetWorkingHelper.normalPost(url: Configs.Network.Square.delMyIssue, params: ["issueId":issueId]) { [weak self] (dict) in
                    self?.models.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
            ///点赞或不点赞
            
            cell.UserLoveBlock = {[weak self](isLike,type,remarkId) in
                self?.likeOrNot(isLike: isLike, type: type,remarkId: remarkId, indexPath: indexPath)
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: CircleRecomedTableCell.className()) as! CircleRecomedTableCell
        cell.guanZhuButClickBlock = {[weak self](isAdd) in
            if isAdd {//关注
                NetWorkingHelper.normalPost(url: Configs.Network.Square.addAttention, params: ["toId":self!.models[indexPath.row].userId]) { [weak self](dict) in
                    self?.models[indexPath.row].isAttention = true
                    
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }else{//取消关注
                NetWorkingHelper.normalPost(url: Configs.Network.Square.delMyAttention, params: ["toId":self!.models[indexPath.row].userId]) { [weak self](dict) in
                    self?.models[indexPath.row].isAttention = false
                    if self!.isDeleAfterCancleAttion {
                        self?.models.remove(at: indexPath.row)
                        self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }else{
                        self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                    
                }
            }
        }
        cell.UserLoveBlock = {[weak self](isLike,type,remarkId) in
            self?.likeOrNot(isLike: isLike, type: type,remarkId: remarkId, indexPath: indexPath)
        }
        cell.setModel(model: models[indexPath.row])
        cell.onTapAvatar = { [weak self] _ in
            guard let self = self else { return }
            if LocalUserInfo.share.userId == self.models[indexPath.row].userId {
                return
            }
            let vc = UserDetailViewController.`init`(withUserId: "\(self.models[indexPath.row].userId)")
            self.navigationController?.pushViewController(vc, isNeedLogin: true, animated: true)
        }
        return cell
    }
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let isTop = scrollView.contentOffset.y - orginY < 0
            if scrollView.contentOffset.y <= 0 { //最顶部
//            if isTop { //向下滑动
                if let block = tableViewScrollToTopOrBottom{
                    if !block(true,scrollView.contentOffset.y - orginY){
                        scrollView.contentOffset.y = 0
                    }
                }
            } //else if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height {//最底部了
            else {//向上
                if let block = tableViewScrollToTopOrBottom{
                    if  !block(false,scrollView.contentOffset.y - orginY){
                        scrollView.contentOffset.y = orginY
                    }
                }
            }
            orginY = scrollView.contentOffset.y
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = models[indexPath.row]
        let vc = IssueDetailViewController.`init`(withIssueId: "\(model.issueId)")
        self.navigationController?.pushViewController(vc, isNeedLogin: true, animated: true)
    }
    
}

//MARK: - 请求数据
extension CircleRecomedTableVC {
    func requistDataList(){
        if  let block = requistBlock {//我的一 评论，关注，点赞，发布
            //        block(block)
            block(self.currPage,{[weak self](models,isNoMore) in
                if self!.currPage == self!.beiginPage{
                    self?.models = models
                }else{
                    self?.models.append(contentsOf: models)
                }
                self?.isNoMore = isNoMore
                self?.tableView.reloadData()
                self?.currPage += 1
            })
        }else{//推荐
            vm.requistRecomdList(currPage: self.currPage){[weak self] (models,isNoMore) in
                if self!.currPage == self!.beiginPage{
                    self?.models = models
                }else{
                    self?.models.append(contentsOf: models)
                }
                self?.currPage += 1
                self?.isNoMore = isNoMore
                self?.tableView.reloadData()
            }
        }
        
    }
}


//MARK: - 点赞或取消点赞
extension CircleRecomedTableVC{
    func likeOrNot(isLike:Bool,type:String,remarkId:String? = nil,indexPath:IndexPath){
        let model = self.models[indexPath.row]
        if isLike {//取消点赞
            var params = ["likeType":type,"nickName":model.showName,"issueId":model.issueId]
            if type == "1" {
                params =  ["likeType":type,"nickName":model.showName,"remarkId":remarkId ?? ""]
            }
            NetWorkingHelper.normalPost(url: Configs.Network.Square.delUserILike , params: params) { [weak  self] (dict) in
                if type == "0"{
                    self?.models[indexPath.row].issueLikeCount -= 1
                    self?.models[indexPath.row].isIssueLike = false
                }else{//评论点赞
            
                    if let index =  model.remarkList.firstIndex(where: { (remark) -> Bool in
                        return remark.remarkId == Int(remarkId ?? "0") ?? 0
                    }){
                        self!.models[indexPath.row].remarkList[index].isRmkLike = false
                        self!.models[indexPath.row].remarkList[index].issueRemkLikeCount -= 1
                    }
                   
                }
               
                if self!.isDeleteAfterCancleLive{
                    if type == "0" {
                        self?.models.remove(at: indexPath.row)
                        self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }else{
                        self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }else{
//                    self?.tableView.reloadData()
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }else{//点赞
            var params = ["likeType":type,"nickName":model.showName,"issueId":model.issueId]
            if type == "1" {
                params = ["likeType":type,"nickName":model.showName,"remarkId":remarkId ?? ""]
            }
            NetWorkingHelper.normalPost(url: Configs.Network.Square.addUserLike, params: params) { [weak self] (dict) in
                if type == "0"{
                    self?.models[indexPath.row].issueLikeCount += 1
                    self?.models[indexPath.row].isIssueLike = true
                }else{//评论点赞
            
                    if let index =  model.remarkList.firstIndex(where: { (remark) -> Bool in
                        return remark.remarkId == Int(remarkId ?? "0") ?? 0
                    }){
                        self!.models[indexPath.row].remarkList[index].isRmkLike = true
                        self!.models[indexPath.row].remarkList[index].issueRemkLikeCount += 1
                    }
                   
                }
                if self!.isDeleteAfterCancleLive{
                    if type == "0" {
                        self?.models.remove(at: indexPath.row)
                        self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }else{
                        self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                   
                }else{
//                    self?.tableView.reloadData()
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
}








