//
//  CircleHomeModel.swift
//  TianXin
//
//  Created by SDS on 2020/10/16.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
//protocol NumOrStringType {
//}
//extension String:NumOrStringType{}
//extension Int:NumOrStringType{}

 protocol CountType {
    var mycount:Int{ get}
}
extension String:CountType{
    var mycount: Int {
        return self.count
    }
}
extension Array:CountType{
    var mycount: Int {
            return self.count
    }
}
extension Dictionary:CountType{
    var mycount: Int {
            return self.count
    }
}
/**

 */
class CircleHomeModel : BaseModel {
  var issueId  = ""
    var  issueVideo:String = ""
     var squareReplyAllCount  = 0
     var recommendId  = "0"
     var issueContent  = "  "
     var nickName  = ""
     var userName  = ""
     var userLogo  = ""
     var userId  = 463
    var isAttention :Bool = false
     var squareRemarkCount  = 0
    var issuePic:[String] = []
     var createTime  = ""
    var isIssueLike: Bool = false
     var issueLikeCount  = 0
    var joinRecommendList:[JoinRecommend]  = [JoinRecommend]()
    var remarkList:[RemarkModel]  = [RemarkModel]()
    ///官网喜欢人数
    var officialLikeCount = 0
    ///"大字报",---官方帖子标题
    var issueTitle = ""
    var showName :String {
        return nickName.count > 0 ? nickName : userName
    }
}
/**
 发帖用户加入的圈子
 */
class JoinRecommend: BaseModel {
    var recommendId  = 0
    var recommendPic  = ""
    var recommendDesc  = ""
    var recommendName  = ""
    var userId  = 0
}
/**
 remarkList:{
 issueId:帖子Id
 remark:帖子内容
 remarkid:评论id
 rmktime: 评论时间
 toId:  发帖子用户Id
 userId:  评论用户id
 userLogo: 用户头像
 userName: 用户名
 }
 */
class RemarkModel: BaseModel {
    var showName:String {
        return nickName.count > 0 ? nickName : userName
    }
          var toId =  0
          var issueId =  ""
    var isRmkLike: Bool =  false
          var issueContent =  ""
          var issueVideo =  ""
          var nickName =  ""
//          var loginIsReply =  null
          var remark =  ""
          var userLogo =  ""
          var userName =  ""
          var userId =  470
       var issuePic:[String] =  []
          var createTime =  "2020-10-16 20:25:42"
          var issueRemkLikeCount =  0
          var issueReplyList =  0
          var remarkId =  0
    var isAttention:String = ""
    var squareRemarkCount:Int = 0
}
