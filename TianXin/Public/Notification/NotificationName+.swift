//
//  NotificationName+.swift
//  TianXin
//
//  Created by pretty on 10/26/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation

extension Notification.Name {
    // 帖子点赞
    // obj ==> "issueId":String, "isLike": Bool
    static let IssueOnLike = Notification.Name(rawValue: "IssueOnLike")
    // 用户关注
    // obj ==> "userId": Int,"isAttention": Bool
    static let UserOnAttention = Notification.Name(rawValue: "UserOnAttention")
    // 帖子评论点赞
    // obj ==> "remarkId": String, "isLike": Bool
    static let RemarkOnLike = Notification.Name(rawValue: "RemarkOnLike")
    // 首页点击menu item
    static let HomeMenuOnTap = Notification.Name(rawValue: "HomeMenuOnTap")
    // 对帖子发表评论
    static let CommentOnIssue = Notification.Name(rawValue: "CommentOnIssue")
    // 点赞电影 ===> id: String, isLike: Bool
    static let LikeMovie = Notification.Name(rawValue: "LikeMovie")
}
