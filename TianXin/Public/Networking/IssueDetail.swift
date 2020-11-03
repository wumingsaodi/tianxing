//
//  IssueDetail.swift
//  TianXin
//
//  Created by pretty on 10/19/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation

struct IssueDetail: Codable {
    var id: Int?
    var issueId: String
    var recommendId: Int?
    var issueContent: String?
    var issueVideo: String?
    var issuePic: [String]?
    var userLogo: String?
    var userName: String?
    var userId: Int
    @BetterBoolCodable var isAttention: Bool
    var squareRemarkCount: Int?
    var createTime: String?
    var issueLikeCount: Int?
    var issuePVCount: Int?
    var collectCount: Int?
    var isSquare: Int?
    var remarkList: [IssueRemark]
    // 精选评论
    var issueJxRemark: [IssueRemark]
    // 帖子发布的圈子
    var joinRecommendList: [CircleItem]?
}

