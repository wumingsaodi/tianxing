//
//  UserInfoModel.swift
//  TianXin
//
//  Created by SDS on 2020/10/7.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
/**
 "userInfo": {
 "other": {
 "birthday": "",
 "qq": "",
 "provinces": "",
 "address": "",
 "sex": 0,
 "wechat": "",
 "avatar": "http://img.bwhou2020.com/1576480523173011.png",
 "realName": "",
 "phone": "",
 "inviteCode": "9571031",
 "name": "1232",
 "id": 2019248988,
 "email": ""
 },
 "gender": 0,
 "signature": null,
 "7Count": null,
 "threeUserId": "2019248988",
 "updateTime": null,
 "extraWatchCount": 0,
 "userName": "1232",
 "userLogo": null,
 "userId": null,
 "isSign": "0",
 "lastSignUp": null,
 "balance": 0,
 "createTime": null,
 "gearPosition": 1,
 "30Count": null,
 "age": null,
 "todayWatchCount": 0,
 "watchCount": 8,
 "coin": 0
 },
 */
import HandyJSON
enum GenderType:Int,HandyJSONEnum {
    case man = 0
    case wuman = 1
    case none = -1
    var toChina:String {
        switch self {
        case .man:
            return "男"
        case .wuman:
        return "女"
        default:
            return ""
        }
    }
}
class UserInfoModel: BaseModel {
    var gender:GenderType = .none
    var  userSign = ""
    var   age =   ""
    var   todayWatchCount = 0
    var    watchCount = 0
    var    coin = 0
    var  userName =  ""
    var nickName = ""
    var  threeUserId = 0
    var  createTime =   ""
    var  updateTime = 0
    var  extraWatchCount = 0
    var userLogo = ""
    var email = ""
    var phone = ""
    var other = UserOtherModel()
    //     var 7Count = ""
    //   var   userLogo = ""
    //   var   userId =   ""
    //    var  isSign = 0
    //    var  lastSignUp =   ""
    //   var   balance = 0
    //  var    gearPosition = 1
    //  var    30Count =   ""
    
}

class UserOtherModel: BaseModel {
    var   birthday = ""
    var    qq = ""
    var    provinces = ""
    var   address = ""
    var   sex = 0
    var   wechat = ""
    var   avatar = ""
    var   realName = ""
//    var   phone = ""
    var   inviteCode = 0
    var   name = ""
    var   id = 0
//    var   email = ""
}
