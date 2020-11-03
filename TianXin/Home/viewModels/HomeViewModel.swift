//
//  HomeViewModel.swift
//  TianXin
//
//  Created by SDS on 2020/9/30.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class HomeViewModel: NSObject {
    
    var homeModel:HomeIndexModel?
    func requistCheckUp(version:Double,_ success:@escaping (_ isNeedDown:Int,_ url:String)->Void){
        let params = ["version":version,"os":"ios"] as [String : Any]
        NetWorkingHelper.normalPost(url: api_checkUp, params: params, success: { (dict) in
            success(dict["isReDownload"] as! Int,dict["url"] as! String)
            
        }) { (error) in
            SDSHUD.showError(error.errMsg)
        }
    }
    /**
     获取首页信息
     */
    func RequistHomeIndex(_ success:@escaping ()->Void) {
        NetWorkingHelper.normalPost(url: api_homeindex, params: [:], success: { (dict) in
            let model = HomeIndexModel.deserialize(from: dict)
            self.homeModel = model
            success()
        }) { (error) in
            SDSHUD.showError(error.errMsg)
        }
    }
    /**
     首页刷新
     */
    func HomeIndexRefresh(type:Int,pageSize:Int = 4,success:@escaping(_ models:[HomeItemModel])->Void) {
        NetWorkingHelper.normalPost(url: api_homeRefresh, params: ["type":type,"pageSize":pageSize]) { (dict) in
            guard  let arr =  dict["movieList"] as? Array<Any>,  let models = [HomeItemModel].deserialize(from:arr )else{
                SDSHUD.showError("首页刷新失败")
                return
            }
            let newModels = models.map({return ($0)!})
            success(newModels)
        }
    }
    /**
     其他类型的视频列表
     */
    func requistHomeOtherList(type:String,currPage:Int,pageSize:Int = 20,success:@escaping(_ modes:[HomeItemModel],_ isNomore:Bool)->Void){
        NetWorkingHelper.normalPost(url: api_HomeOtherVCList, params: ["type":type,"currPage":currPage,"pageSize":pageSize]) { (dict) in
            guard let movieList = dict["movieList"] as? Array<Any>, let models = [HomeItemModel].deserialize(from: movieList) else{
                SDSHUD.showError("获取数据失败")
                return
            }
           let   newModels = models.map({return ($0)!})
            let isNomore = newModels.count == pageSize ? false: true
                success(newModels,isNomore)
         }
    }
}
