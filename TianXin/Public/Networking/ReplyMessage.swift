//
//  ReplyMessage.swift
//  TianXin
//
//  Created by pretty on 10/20/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation

struct ReplyMessage: Codable {
    var toId: Int?
    var issueId: String?
    var remark: String?
    var issueContent: String?
    var issueVideo: String?
    var nickName: String?
    var userLogo: String?
    var userName: String?
    var userId: Int?
    var squareRemarkCount: Int
    var issuePic: [String]?
    var createTime: String?
    var replyMessage: String?
    var replyId: Int?
    var isIssueLike: String?
    var issueLikeCount: Int
    var id: Int
    var remarkId: Int
    var remarkList: [IssueRemark]
}
