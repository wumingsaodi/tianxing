//
//  CircleIssueUserInfo.swift
//  TianXin
//
//  Created by SDS on 2020/10/21.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class CircleIssueUserInfo: BaseModel {
    var isAttention = ""
 var myExtensionCode =  ""
       var nickName =  ""
       var otherExtensionCode =  ""
       var userName =  ""
    var showName:String {
        return nickName.count > 0 ? nickName : userName
    }
       var userLogo =  ""
       var usColCount =  0
       var careCount =  0
       var tripCount =  0
       var recommendCount =  0
       var usReplyCount =  0
       var beCaredCount =  0
       var id =  0
       var publishCount =  0
    
}
