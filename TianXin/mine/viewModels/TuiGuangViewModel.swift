//
//  TuiGuangViewModel.swift
//  TianXin
//
//  Created by SDS on 2020/10/13.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import HandyJSON
class inviterItem: BaseModel {
   var createTime = ""
   var  phone = ""
   var nickName = ""
}
class TuiGuangUserInfo: BaseModel {
    var  phone =  ""
    var myExtensionCode = ""
    var extensionCount = 0
    var promotUrl = ""
}
class TuiGuangModel: BaseModel {
    var userInfo: TuiGuangUserInfo = TuiGuangUserInfo()
    var inviter:[inviterItem] = [inviterItem]()
}


class TuiGuangViewModel: NSObject {
    /**
     /gl/user/myPromoting
     */
    func requistMyPromote(success:@escaping (_ model:TuiGuangModel)->Void)  {
        NetWorkingHelper.normalPost(url: api_myPromoting, params: [:]) { (dict) in
            guard   let model = TuiGuangModel.deserialize(from: dict) else{
                return
            }
            success(model)
        }
           
            
}
}
