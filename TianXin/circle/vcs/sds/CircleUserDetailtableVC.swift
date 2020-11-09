//
//  CircleUserDetailtableVC.swift
//  TianXin
//
//  Created by SDS on 2020/10/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import MJRefresh
class CircleUserDetailtableVC: SDSBaseVC {
    ///全部圈子请求成功之后才能拿到head消息，去回掉head
    var setHedBlock:(()->Void)?
    
    var orginY:CGFloat = .zero
    var models:[CircleHomeModel] = [CircleHomeModel](){
        didSet{
            if models.count > 0 {
                tableView.noDataView.isHidden = true
            }else{
                tableView.noDataView.isHidden = false
            }
        }
    }
    var isNoMore = false
    var currPage:Int = 1
    var requistBlock:((_ currPage: Int, _ success:@escaping ((_ models:[CircleHomeModel],_ isNoMore:Bool)->Void))->Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.requistDataList()
        
    }
    
    lazy var tableView:SDSTableView =  {
        let tab = SDSTableView.CreateTableView()
        tab.page = 1
        tab.delegate = self
        tab.dataSource = self
        tab.register(CircleDetailCell.self, forCellReuseIdentifier: CircleDetailCell.className())
//        tab.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {[weak self] in
//            self!.currPage = self!.beiginPage
//            self?.requistDataList()
//
//        })
        tab.mj_footer = MJRefreshFooter.init(refreshingBlock: {[weak self, weak tab] in
            if self!.isNoMore{
                tab?.mj_footer?.endRefreshing()
                return
            }
            self!.requistDataList()
        })
    
       
        tab.estimatedRowHeight = 200
        return tab
    }()

}


extension CircleUserDetailtableVC:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return  100
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CircleDetailCell.className()) as! CircleDetailCell
        cell.setModel(model: models[indexPath.row])
        cell.onTapAvatar = { [weak self] model in
            if LocalUserInfo.share.userId == model.userId {
                return
            }
            let vc = UserDetailViewController.`init`(withUserId: "\(model.userId)")
            self?.navigationController?.pushViewController(vc, isNeedLogin: true, animated: true)
        }
        cell.guanZhuButClickBlock = {[weak self](isAdd) in
            if isAdd {//关注
                NetWorkingHelper.normalPost(url: Configs.Network.Square.addAttention, params: ["toId":self!.models[indexPath.row].userId]) { [weak self](dict) in
                    self?.models[indexPath.row].isAttention = true
                    
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }else{//取消关注
                NetWorkingHelper.normalPost(url: Configs.Network.Square.delMyAttention, params: ["toId":self!.models[indexPath.row].userId]) { [weak self](dict) in
                    self?.models[indexPath.row].isAttention = false
                        self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                    
                }
            }
        }
        cell.UserLoveBlock = {[weak self](isLike,type,remarkId) in
            self?.likeOrNot(isLike: isLike, type: type,remarkId: remarkId, indexPath: indexPath)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = models[indexPath.row]
        let vc = IssueDetailViewController.`init`(withIssueId: model.issueId)
        self.navigationController?.pushViewController(vc, isNeedLogin: true, animated: true)
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 { //最顶部
            if let block = tableViewScrollToTopOrBottom{
                if !block(true,scrollView.contentOffset.y - orginY){
                    scrollView.contentOffset.y = 0
                }
            }
            //else if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height
        }//else if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height {//最底部了
        else{//向上
            if let block = tableViewScrollToTopOrBottom{
                if  !block(false,scrollView.contentOffset.y - orginY){
                    scrollView.contentOffset.y = orginY
                }
            }
        }
        orginY = scrollView.contentOffset.y
    }

    func requistDataList() {
        if self.requistBlock != nil {
            self.requistBlock!(self.currPage,{[weak  self](models,isNoMore) in
                if let headBlock = self?.setHedBlock{
                    headBlock()
                }
                if self?.currPage == 1 {
                    self?.models.append(contentsOf: models)
                }else{
                    self?.models = models
                }
                self?.currPage += 1
                self?.tableView.reloadData()
            })
        }
        
        
    }
}

//MARK: - 点赞或取消点赞
extension CircleUserDetailtableVC{
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
            
                    if let index =  model.remarkList.firstIndex(where: { [weak self](remark) -> Bool in
                        return remark.remarkId == Int(remarkId ?? "0") ?? 0
                    }){
                        self!.models[indexPath.row].remarkList[index].isRmkLike = false
                        self!.models[indexPath.row].remarkList[index].issueRemkLikeCount -= 1
                    }
                   
                }

                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)

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

//                    self?.tableView.reloadData()
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
}
