//
//  IssueReply.swift
//  TianXin
//
//  Created by pretty on 10/20/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation

struct IssueReply: Codable {
    var id: Int
    var remarkId: Int
    var toId: Int
    var issueId: String
    var replyType: Int // 1 一级回复  2 二级回复
    var isRmkLike: Int?
    var nickName: String?
    var userLogo: String?
    var userName: String?
    var replyNickName: String?
    var userId: Int?
    var createTime: String?
    var replyMessage: String?
    var replyName: String?
    var issueRemkLikeCount: Int?
    var isLikeCount: Int?
    var replyId: Int?
    var remark: String?
}

struct IssueComment: Codable {
    var issueId: String?
    var toId: Int
    var isAttention: Int?
    var createTime: String?
    var nickName: String?
    var userName: String?
    var userLogo: String?
    var remarkId: Int
    var userId: Int
    var remark: String?
    var isRmkLike: Int?
    var replyList: [IssueReply]?
    var num: Int?
}
