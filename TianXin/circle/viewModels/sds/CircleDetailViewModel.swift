//
//  CircleDetailViewModel.swift
//  TianXin
//
//  Created by SDS on 2020/10/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
let CircleDetailViewModelDefualtPage :Int = 6
class CircleDetailViewModel: NSObject {
    var infoModel:TopRecomedModel?
    /**
     
     圈子精华帖子列表
     */
    func requistcircleIssueEssenceList(recommendId:String,currPage:Int,pageSize:Int = CircleDetailViewModelDefualtPage,success:@escaping( _ models:[CircleHomeModel],_ isNomore:Bool)->Void) {
        NetWorkingHelper.normalPost(url: api_circleEssenceIssueList, params: ["recommendId":recommendId,"currPage":currPage,"pageSize":pageSize]) { (dict) in
            guard let listDict = dict["circleIssueList"] as?[Any],let models = [CircleHomeModel].deserialize(from: listDict)else{
                      return
                  }
                  for i in 0..<models.count {
                      
                      let subListDict = listDict[i] as? [String:Any]
                      let subDict = subListDict!["circleIssAllRemark"] as? Array<Any>
                      if  subDict != nil && subDict?.count ?? 0 > 0 {
                          let remarks = [RemarkModel].deserialize(from: subDict)
                          let newRarks  = remarks!.map({return ($0)!})
                          models[i]?.remarkList = newRarks
                      }
                  }
            let  newModels =  models.map({return ($0)!})
            let isNomore = models.count == pageSize ? false: true
            success(newModels,isNomore)
        }
    }
    /**
     圈子全部帖子列表
     */
    func requistAllIssueList(recommendId:String,currPage:Int,pageSize:Int = CircleDetailViewModelDefualtPage,success:@escaping( _ models:[CircleHomeModel],_ isNomore:Bool)->Void){
        NetWorkingHelper.normalPost(url: api_circleAllIssueList, params:["recommendId":recommendId,"currPage":currPage,"pageSize":pageSize]) { (dict) in
            
            guard let listDict = dict["circleIssueList"] as?[Any],let models = [CircleHomeModel].deserialize(from: listDict),let infoDict = (dict["recommendInfo"] as?[Any])?.first as? [String:Any],let infoModel = TopRecomedModel.deserialize(from: infoDict) else{
                      return
                  }
            infoModel.isJoin = (dict["isJoin"] as? Int ?? 0) > 0
            infoModel.circleAllCount = dict["circleAllCount"] as? Int ?? 0
            infoModel.circleIssueCount = dict["circleIssueCount"] as? Int ?? 0
                  for i in 0..<models.count {
                      
                      let subListDict = listDict[i] as? [String:Any]
                      let subDict = subListDict!["circleIssAllRemark"] as? Array<Any>
                      if  subDict != nil && subDict?.count ?? 0 > 0 {
                          let remarks = [RemarkModel].deserialize(from: subDict)
                          let newRarks  = remarks!.map({return ($0)!})
                          models[i]?.remarkList = newRarks
                      }
                  }
            let  newModels =  models.map({return ($0)!})
            let isNomore = models.count == pageSize ? false: true
            self.infoModel = infoModel
            success(newModels,isNomore)
            
        }
    }
    /**
     
     查询发帖用户主页
     */
//    func requistIssueUserInfo(toId:String,success:@escaping(_ model:CircleIssueUserInfo)->Void){
//        NetWorkingHelper.normalPost(url: api_issueUserInfo, params: ["toId":toId]) { (dict) in
//            guard let isAttention = dict["isAttention"],let userDictARR = dict["issueUserInfoList"] as? [Any],let userDict = userDictARR.first as? [String:Any], let model = CircleIssueUserInfo.deserialize(from: userDict)else{
//                SDSHUD.showError("解析错误")
//                return
//            }
//            model.isAttention = isAttention as! String
//            success(model)
//        }
//    }
}
