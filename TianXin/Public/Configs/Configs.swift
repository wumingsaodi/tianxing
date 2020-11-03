//
//  Configs.swift
//  TianXin
//
//  Created by pretty on 10/7/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

struct Configs {
    struct App {
        static let bundleIdentifier = "com.tianXin.www.TianXin"
        static let env: Configs.App.Env = .dev
        // 分享出去的名字
        static let shareName = "甜杏App"
        // 分享出去的URL
        static let shareURL = URL(string: "http://google.com")!
        // UUID
        static let uuid = UIDevice.current.identifierForVendor!.uuidString
    }
    struct Network {
        static let loggingEnabled = true
        static let baseUrl = "http://tianxing.viphk.ngrok.org"
    }
    struct Dimensions {
        static let cornerRadius: CGFloat = 5
        static let screenWidth = UIScreen.main.bounds.width
        static let screenHeight = UIScreen.main.bounds.height
        static let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        static let safeNavigationBarHeight = statusBarHeight + 44
        static let safeAreaBottom = statusBarHeight > 20 ? 34 : 0 as CGFloat
        static let safeBottomBarHeight = safeAreaBottom + 49
        // UI 参考系 iPhone 6
        static let referenceScreenSize = CGSize(width: 375, height: 667)
    }
    struct Path {
        static let Documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        static let Tmp = NSTemporaryDirectory()
    }
    
    struct Theme {
        struct Color {
            // 主题色
            static let primary = UIColor(red: 0.99, green: 0.58, blue: 0.06, alpha: 1) // 橘黄色
            // 界面背景色
            static let backgroud = UIColor(hex: 0xF7F8FA)
            // 内容背景色
            static let contentBackground = UIColor(white: 0.96, alpha: 1)
            // 按钮高亮
            static let highlight = UIColor(red: 0.98, green: 0.71, blue: 0.36, alpha: 1)
            // 按钮不可用
            static let disabled = UIColor(red: 0.8, green: 0.79, blue: 0.81, alpha: 1)
            // 标题颜色
            static let dark = UIColor.black
            // 文本
            static let title = UIColor(red: 0.23, green: 0.22, blue: 0.17, alpha: 1)
            static let content = UIColor(white: 0.36, alpha: 1)
            // 额外信息，诸如时间显示、点赞数等
            static let info = UIColor(white: 0.61, alpha: 1)
            static let grey = UIColor(red: 0.53, green: 0.51, blue: 0.49, alpha: 1)
        }
    }
    
    static let publicKey = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC6amslTkuX0LsXJd8KVkWp1HdppmqrynpS4kykQquQHyEmzunIMJxqdZgul9Fn/VCoj/p9+uesD50QXB4eQCl/sAXM/kFq2fSrVdr7ZgyPIL/pFAhimEmEv0Adg1fasZ7kWbf6OTIitO1BJ0FVDdtJ+3dP4BZMNJ6zDW3EQiLg/QIDAQAB"
}

// 根据UI设计图参考屏大小，自动适应当前屏幕尺寸
extension CGFloat {
    var fitting: CGFloat {
        return self * (Configs.Dimensions.screenWidth / Configs.Dimensions.referenceScreenSize.width)
    }
}

// app测试环境
extension Configs.App {
    enum Env {
        case dev // 开发环境
        case multivariate // 灰度测试
        case distribution // 正式发布
    }
}

/// 专题相关URL
extension Configs.Network {
    struct Topic {
        // 取消点赞
        static let delMovieILike = "/gl/topic/delMovieILike"
        // 最近常搜
        static let recentSearchVideo = "/gl/topic/recentSearchVideo"
        // 单个最近常搜
        static let delSearchVideo = "/gl/topic/delSearchVideo"
        // 电影点赞
        static let addMovieILike = "/gl/topic/addMovieILike"
        // 专题电影列表
        static let topicMovieList = "/gl/topic/topicMovieList"
        // 观看电影
        static let topicWatchMovie = "/gl/topic/topicWatchMovie"
        // 搜索专题电影名
        static let searchTopicVideo = "/gl/topic/searchTopicVideo"
        // 用户对电影评论回复
        static let addMovieReply = "/gl/topic/addMovieReply"
        // 电影评论回复详情
        static let topicMovieRemarkDetail = "/gl/topic/topicMovieRemarkDetail"
        // 相关推荐电影
        static let refMovieList = "/gl/topic/refMovieList"
        // 批量删除最近搜索
        static let batchDelSearch = "/gl/topic/batchDelSearch"
        // 专题推荐
        static let topicVideoRecommend = "/gl/topic/topicVideoRecommend"
        // 取消电影评论
        static let delMyMovieRemark = "/gl/topic/delMyMovieRemark"
        // 电影评论
        static let addMovieRemark = "/gl/topic/addMovieRemark"
        // 取消电影评论回复
        static let delMyMovieReply = "/gl/topic/delMyMovieReply"
    }
    struct User {
        // 收藏列表
        static let movieFavorites = "/gl/user/myLike"
        // 收藏
        static let addLike = "/gl/user/addLike"
        // 包网获取包网所有场馆列表
        static let queryGameByType = "/gl/user/queryGameByType"
        // 包网获取登录游戏场馆URL
        static let queryGameUrl = "/gl/user/queryGameUrl"
    }
    struct Square {
        // 发布内容
        static let addIssue = "/gl/square/addIssue"
        ///删除发布的内容
        static let delMyIssue =   "/gl/square/delMyIssue"
        // 圈子列表
        static let squareList = "/gl/square/squareList"
        // 我加入的圈子
        static let checkJoinList = "/gl/square/checkJoinList"
        // 加入圈子
        static let addMyJoin = "/gl/square/addMyJoin"
        // 退出圈子
        static let delMyJoin = "/gl/square/delMyJoin"
        // 用户主页
        static let checkIssueUserInfo = "/gl/square/checkIssueUserInfo"
        // 用户发布的帖子列表
        static let checkUserPubIssueList = "/gl/square/checkUserPubIssueList"
        // 用户主页足迹列表
        static let checkUserTripInfo = "/gl/square/checkUserTripInfo"
        // 用户主页收藏列表
        static let checkUserCollectInfo = "/gl/square/checkUserCollectInfo"
        // 用户主页对评论回复列表
        static let checkUserReplyMessage = "/gl/square/checkUserReplyMessage"
        // 帖子详情
        static let checkCareIssueDetail = "/gl/square/checkCareIssueDetail"
        // 评论回复列表
        static let checkCircleUserReplyMessage = "/gl/square/checkCircleUserReplyMessage"
        // 用户关注
        static let addAttention = "/gl/square/addAttention"
        ///取消关注
        static let delMyAttention = "/gl/square/delMyAttention"
        // 点赞
        static let addUserLike = "/gl/square/addUserLike"
        // 取消点赞
        static let delUserILike = "/gl/square/delUserILike"
        // 用户评论
        static let addRemark = "/gl/square/addRemark"
        // 添加回复
        static let addReply = "/gl/square/addReply"
        // 添加我的收藏
        static let addMyCollect = "/gl/square/addMyCollect"
        // 取消我的收藏
        static let delMyCollect = "/gl/square/delMyCollect"
        // 用户主页粉丝数
        static let checkUserHomeFans = "/gl/square/checkUserHomeFans"
        // 用户关注
        static let checkUserBeCared = "/gl/square/checkUserBeCared"
    }
}
