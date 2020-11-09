//
//  PublishIssue.swift
//  TianXin
//
//  Created by pretty on 10/19/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation

// 发布的帖子列表
struct PublishIssue: Codable {
    var issueId: String
    var userLogo: String?
    var nickName: String?
    var userName: String?
    var userId: Int
    var issuePic: [String]?
    var createTime: String?
    @BetterBoolCodable var isIssueLike: Bool
    var issueContent: String?
    var issueVideo: String?
    var issueLikeCount: Int?
    var issueAllReplyCount: Int?
    var squareRemarkCount: Int?
    var joinRecommendList: [CircleItem]?
    var gender: Int?
}

struct IssueRemark: Codable {
    var remarkId: Int
    var toId: Int
    var userId: Int
    var userLogo: String?
    var userName: String?
    var createTime: String?
    var issueId: String?
    var nickName: String?
    var remark: String?
    var issueRemkLikeCount: Int
    var issueRemkReplyCount: Int
    @BetterBoolCodable var isRmkLike: Bool
}
