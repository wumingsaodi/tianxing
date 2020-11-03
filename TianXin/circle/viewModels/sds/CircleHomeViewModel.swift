//
//  CircleHomeViewModel.swift
//  TianXin
//
//  Created by SDS on 2020/10/17.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
let CircleHomDefualtPage:Int = 6
class CircleHomeViewModel: NSObject {
  
//    var homeRecommendModles:[CircleHomeModel]?
    /**
     推挤首页显示的列表
     */
    func requisttopRecomdCellList(success:@escaping(_ models:[TopRecomedModel])->Void)  {
        NetWorkingHelper.normalPost(url: api_topRecommendCellList, params: [:]) { (dict) in
            guard let  dataDict = (dict["recommendSquare"] as? Array<Any>),let models = [TopRecomedModel].deserialize(from: dataDict)else{
                return
            }
             let newModels = models.map({($0)!})
                success(newModels)
           
    }
    }
    /**
     获取推荐列表
     */
    func requistRecomdList(currPage:Int,pageSize:Int = CircleHomDefualtPage,success:@escaping(_ models:[CircleHomeModel],_ isNoMore:Bool) ->Void){
        NetWorkingHelper.normalPost(url: api_CircleHomeRecommendList, params: ["currPage":currPage,"pageSize":pageSize]) { (dict) in
            guard let  arr:Array<Any> = (dict["squareIssueList"] as? Array<Any>),let models = [CircleHomeModel].deserialize(from: arr),let officialList = dict["officialList"] as? Array<Any>, let offcialModels = [CircleHomeModel].deserialize(from: officialList) else{
                return
            }
               
              var newModels = models.map({return ($0)! })
            newModels.insert(contentsOf: offcialModels.map({return ($0)! }), at: 0)
//                self.homeRecommendModles = newModels
            let isNomore =  newModels.count < pageSize ? true : false
                success(newModels,isNomore)

          
        }
    }
    /**
     获取已关注列表
     */
    func requistMyCareList(currPage:Int,pageSize:Int = CircleHomDefualtPage,success:@escaping(_ models:[CircleHomeModel],_ isNoMore:Bool) ->Void){
        NetWorkingHelper.normalPost(url: api_CircleHomeMyCareList, params: ["currPage":currPage,"pageSize":pageSize]) { (dict) in
            guard let  arr:Array<Any> = (dict["myCareList"] as? Array<Any>)else{
                return
            }
         let  newArr =   arr.map { (item) -> [String:Any] in
                var dict = item as! [String:Any]
                let  careArr = dict["careIssueList"] as! Array<Any>
            if careArr.count > 0 {
                let careDict =  careArr.first  as! [String:Any]
                careDict.forEach { (key,value) in
                    dict.updateValue(value, forKey: key)
             
                }
            }
               
               return dict
            }
            guard let models = [CircleHomeModel].deserialize(from: newArr)else{
                return
            }
            
              let newModels = models.map({return ($0)! })

            let isNomore =  newModels.count < pageSize ? true : false
                success(newModels,isNomore)

          
        }
    }
    /**
     获取已点赞
     */
    func requistMyLikeList(currPage:Int,pageSize:Int = CircleHomDefualtPage,success:@escaping(_ models:[CircleHomeModel],_ isNoMore:Bool) ->Void){
        NetWorkingHelper.normalPost(url: api_CircleHomeMyLikeList, params: ["currPage":currPage,"pageSize":pageSize]) { (dict) in
            guard let  arr:Array<Any> = (dict["myLikeList"] as? Array<Any>),let models = [CircleHomeModel].deserialize(from: arr)else{
                return
            }
           
              let newModels = models.map({return ($0)! })

            let isNomore =  newModels.count < pageSize ? true : false
                success(newModels,isNomore)

          
        }
    }
    /**
     获取已评论
     */
    func requistMyRemarkList(currPage:Int,pageSize:Int = CircleHomDefualtPage,success:@escaping(_ models:[RemarkModel],_ isNoMore:Bool) ->Void){
        NetWorkingHelper.normalPost(url: api_CircleHomeMyRemarkList, params: ["currPage":currPage,"pageSize":pageSize]) { (dict) in
            guard let  arr:Array<Any> = (dict["remarkList"] as? Array<Any>),let models = [RemarkModel].deserialize(from: arr)else{
                return
            }
           
              let newModels = models.map({return ($0)! })
            let isNomore =  newModels.count < pageSize ? true : false
                success(newModels,isNomore)

          
        }
    }
    /**
     获取已发布列表
     */
    func requistMyIssueList(currPage:Int,pageSize:Int = CircleHomDefualtPage,success:@escaping(_ models:[CircleHomeModel],_ isNoMore:Bool) ->Void){
        NetWorkingHelper.normalPost(url: api_CircleHomeMyIssueList, params: ["currPage":currPage,"pageSize":pageSize]) { (dict) in
            guard let  arr:Array<Any> = (dict["myIssueList"] as? Array<Any>),let models = [CircleHomeModel].deserialize(from: arr)else{
                return
            }
           
              let newModels = models.map({return ($0)! })
              
            let isNomore =  newModels.count < pageSize ? true : false
                success(newModels,isNomore)

          
        }
    }
    /**
     获取已收藏列表
     */
    func requistMyCollectList(currPage:Int,pageSize:Int = CircleHomDefualtPage,success:@escaping(_ models:[CircleHomeModel],_ isNoMore:Bool) ->Void){
        NetWorkingHelper.normalPost(url: api_CircleHomeMyCollectList, params: ["currPage":currPage,"pageSize":pageSize]) { (dict) in
            guard let  arr:Array<Any> = (dict["myCollectList"] as? Array<Any>),let models = [CircleHomeModel].deserialize(from: arr)else{
                return
            }
           
              let newModels = models.map({return ($0)! })
            let isNomore =  newModels.count < pageSize ? true : false
                success(newModels,isNomore)

          
        }
    }
    /**
     删除已评论的内容
     */
    func reuestDelMyRemark(remarkId:String,success:@escaping()->Void){
        NetWorkingHelper.normalPost(url: api_CircleHomeMyRemarkDel, params: ["remarkId":remarkId]) { (dict) in
            success()
        }
    }
}
