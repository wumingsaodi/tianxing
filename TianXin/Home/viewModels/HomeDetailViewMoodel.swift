//
//  HomeDetailViewMoodel.swift
//  TianXin
//
//  Created by SDS on 2020/10/15.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
class HomeMovieItem: BaseModel {
    var  category = ""
    var id = ""
    var   keywords:[String] = [String]()
    var name = ""
    var pic = ""
    var time = ""
    var  url = ""
    var loveNums = 0
    var historyNum = 0
    
}
class HomedetailModel: BaseModel {
    var guess:[HomeItemModel] =  [HomeItemModel]()
    ///是否收藏
    var ilike = false
    var movie:HomeMovieItem = HomeMovieItem()
    var residue = 0
    var totalCount = 0
    //是否点赞
    var isMovLike:Bool = false
    
}

class HomeDetailViewMoodel: NSObject {
    
    func requistMovieDetail(id:String,success:@escaping(_ model: HomedetailModel)->Void){
        NetWorkingHelper.normalPost(url: api_homeDetail, params: ["id":id,"uuid":getUUID()]) { (dict) in
            guard let model = HomedetailModel.deserialize(from: dict)else{
                return
            }
            success(model)
        } fail: { (error) in
            if error.errMsg == "-1"{
                SDSHUD.showError("该电影你的观看记录已用完")
            }else{
                SDSHUD.showError(error.errMsg)
            }
        }
        
    }
}
