//
//  HomeVideoSearchViewModel.swift
//  TianXin
//
//  Created by SDS on 2020/10/24.
//  Copyright © 2020 SDS. All rights reserved.
//
import HandyJSON
struct searchVideoModel:HandyJSON {
 var id = ""
       var pic = ""
       var name = ""
       var category = ""
       var keywords = [String]()
       var historyNum = 0
       var loveNums = 0
     var canLove:Bool = false
}

import UIKit
let SerchVideoDefaultPageSize:Int = 10
class HomeVideoSearchViewModel: NSObject {
    func requestSearchVideo(keyWord:String,currPage:Int,pageSize:Int = SerchVideoDefaultPageSize,success:@escaping(_ models:[searchVideoModel],_ isNotMore:Bool)->Void){
        NetWorkingHelper.normalPost(url: api_homeVideoSearch ,params: ["keyWord":keyWord,"currPage":currPage,"pageSize":pageSize]) { (dict) in
            guard let modelsDict = dict["movieList"] as? [Any],let models = [searchVideoModel].deserialize(from: modelsDict)else{
                SDSHUD.showError("解析错误")
                return
            }
            let newModels = models.map({return ($0)!})
            let isNoMore = newModels.count >= pageSize ? false : true
            success(newModels,isNoMore)
        }
    }
}
