//
//  Square.swift
//  TianXin
//
//  Created by pretty on 10/15/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import Moya

enum SquareApi {
    // 用户发布
    case addIssue(remark: String, isSquare: Bool, recommendId: String?, issuePic: String?, issueVideo: String?)
    // 圈子列表
    case squareList
    // 我加入的圈子
    case checkJoinList(toId: String?)
    // 加入圈子
    case addMyJoin(recommendId: String)
    // 退出圈子
    case delMyJoin(recommendId: String)
    // 发帖用户主页
    case checkIssueUserInfo(toId: String)
    // 用户发布的帖子列表
    case checkUserPubIssueList(toId: String, currPage: Int, pageSize: Int)
    // 用户主页对评论回复列表
    case checkUserReplyMessage(toId: String, currPage: Int, pageSize: Int)
    // 用户主页收藏列表
    case checkUserCollectInfo(toId: String, currPage: Int, pageSize: Int)
    // 用户主页足迹列表
    case checkUserTripInfo(toId: String, currPage: Int, pageSize: Int)
    // 帖子详情
    case checkCareIssueDetail(issueId: String, currPage: Int, pageSize: Int)
    // 评论回复列表
    case checkCircleUserReplyMessage(remarkId: String, currPage: Int, pageSize: Int)
    // 关注用户
    case addAttention(toId: String)
    // 取关用户
    case delMyAttention(toId: String)
    // 点赞
    // likeType ==> 点赞类型(0-帖子,1-评论,2-回复)
    case addUserLike(likeType: String, issueId: String?, remarkId: String?, replyId: String?, nickName: String?)
    // 取消点赞
    case delUserILike(issueId: String?, remarkId: String?, replyId: String?)
    // 用户评论
    case addRemark(issueId: String, remark: String, nickName: String?)
    // 添加回复 replyType ===> 回复类型(1-一级回复,2-二级回复)
    case addReply(replyMsg: String, toId: String, replyType: String, issueId: String?, remarkId: String?, replyId: String?)
    // 添加我的收藏
    case addMyCollect(issueId: String, nickName: String?)
    // 取消我的收藏
    case delMyCollect(issueId: String)
    // 用户主页粉丝
    case checkUserHomeFans(toId: String, page: Int, pageSize: Int)
    // 用户关注用户列表
    case checkUserBeCared(toId: String, page: Int, pageSize: Int)
}

extension SquareApi: TargetType {
    var path: String {
        switch self {
        case .addIssue: return Configs.Network.Square.addIssue
        case .squareList: return Configs.Network.Square.squareList
        case .checkJoinList: return Configs.Network.Square.checkJoinList
        case .addMyJoin: return Configs.Network.Square.addMyJoin
        case .delMyJoin: return Configs.Network.Square.delMyJoin
        case .checkIssueUserInfo: return Configs.Network.Square.checkIssueUserInfo
        case .checkUserPubIssueList: return Configs.Network.Square.checkUserPubIssueList
        case .checkUserReplyMessage: return Configs.Network.Square.checkUserReplyMessage
        case .checkUserCollectInfo: return Configs.Network.Square.checkUserCollectInfo
        case .checkUserTripInfo: return Configs.Network.Square.checkUserTripInfo
        case .checkCareIssueDetail: return Configs.Network.Square.checkCareIssueDetail
        case .checkCircleUserReplyMessage: return Configs.Network.Square.checkCircleUserReplyMessage
        case .addAttention: return Configs.Network.Square.addAttention
        case .delMyAttention: return Configs.Network.Square.delMyAttention
        case .addUserLike: return Configs.Network.Square.addUserLike
        case .delUserILike: return Configs.Network.Square.delUserILike
        case .addRemark: return Configs.Network.Square.addRemark
        case .addReply: return Configs.Network.Square.addReply
        case .addMyCollect: return Configs.Network.Square.addMyCollect
        case .delMyCollect: return Configs.Network.Square.delMyCollect
        case .checkUserHomeFans: return Configs.Network.Square.checkUserHomeFans
        case .checkUserBeCared: return Configs.Network.Square.checkUserBeCared
        }
    }
    var task: Task {
        var params: [String: Any] = [:]
        switch self {
        case let .addIssue(remark, isSquare, recommendId, issuePic, issueVideo):
            params["remark"] = remark
            params["isSquare"] = isSquare ? 1 : 0
            if let recommendId = recommendId {
                params["recommendId"] = recommendId
            }
            if let pic = issuePic {
                params["issuePic"] = pic
            }
            if let video = issueVideo {
                params["issueVideo"] = video
            }
        case let .addMyJoin(recommendId),
             let .delMyJoin(recommendId):
            params["recommendId"] = recommendId
        case let .checkIssueUserInfo(toId),
             let .addAttention(toId),
             let .delMyAttention(toId):
            params["toId"] = toId
        case let .checkUserPubIssueList(toId, currPage, pageSize),
             let .checkUserReplyMessage(toId, currPage, pageSize),
             let .checkUserCollectInfo(toId, currPage, pageSize),
             let .checkUserTripInfo(toId, currPage, pageSize):
            params["toId"] = toId
            params["currPage"] = currPage
            params["pageSize"] = pageSize
        case let .checkCareIssueDetail(issueId, currPage, pageSize):
            params["issueId"] = issueId
            params["currPage"] = currPage
            params["pageSize"] = pageSize
        case let .checkCircleUserReplyMessage(remarkId, currPage, pageSize):
            params["currPage"] = currPage
            params["pageSize"] = pageSize
            params["remarkId"] = remarkId
        case let .addUserLike(likeType, issueId, remarkId, replyId, nickName):
            params["likeType"] = likeType
            if let issueId = issueId {
                params["issueId"] = issueId
            }
            if let remarkId = remarkId {
                params["remarkId"] = remarkId
            }
            if let replyId = replyId {
                params["replyId"] = replyId
            }
            if let nickName = nickName {
                params["nickName"] = nickName
            }
        case let .delUserILike(issueId, remarkId, replyId):
            if let issueId = issueId {
                params["issueId"] = issueId
            }
            if let remarkId = remarkId {
                params["remarkId"] = remarkId
            }
            if let replyId = replyId {
                params["replyId"] = replyId
            }
        case let .addRemark(issueId, remark, nickName):
            params["issueId"] = issueId
            params["remark"] = remark
            if let nickname = nickName {
                params["nickName"] = nickname
            }
        case let .addReply(replyMsg, toId, replyType, issueId, remarkId, replyId):
            params["replyMsg"] = replyMsg
            params["toId"] = toId
            params["replyType"] = replyType
            if let issueId = issueId {
                params["issueId"] = issueId
            }
            if let remarkId = remarkId {
                params["remarkId"] = remarkId
            }
            if let replyId = replyId {
                params["replyId"] = replyId
            }
        case let .addMyCollect(issueId, nickName):
            params["issueId"] = issueId
            if let nickname = nickName {
                params["nickName"] = nickname
            }
        case let .delMyCollect(issueId):
            params["issueId"] = issueId
        case let .checkUserHomeFans(toId, page, pageSize),
             let .checkUserBeCared(toId, page, pageSize):
            params["toId"] = toId
            params["currPage"] = page
            params["pageSize"] = pageSize
        case let .checkJoinList(toId):
            params["toId"] = toId ?? LocalUserInfo.share.userId
        case .squareList: break
        }
        // 全局处理userid参数
        params["userId"] = LocalUserInfo.share.userId ?? ""
        params = customGenerate(params)
        return .requestParameters(parameters: params, encoding: URLEncoding.default)
    }
    var sampleData: Data { return Data() }
}
