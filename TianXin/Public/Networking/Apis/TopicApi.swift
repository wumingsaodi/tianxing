//
//  TopicApi.swift
//  TianXin
//
//  Created by pretty on 10/7/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import Moya


enum TopicApi {
    // 取消点赞
    // movieId 视频id; remarkId 评论id
    case delMovieILike(movieId: String?, remarkId: String?)
    // 最近搜索
    case recentSearchVideo
    // 单个删除最近搜索
    case delSearchVideo(searchId: String)
    // 删除所有最近搜索
    case delAllSearch
    // 电影点赞
    case addMovieILike(movieId: String?, remarkId: String?, likeType: TopicApi.LikeType)
    // 专题推荐
    case topicVideoRecommend
    // 专题电影列表
    case topicMovieList(columnId: Int, page: Int, pageSize: Int)
    // 搜索专题电影名
    case searchTopicMovie(keyWord: String, currPage: Int, pageSize: Int)
    // 观看电影
    case topicWatchMovie(movieId: String, columnId: String, page: Int, pageSize: Int)
    // 电影评论回复详情
    case topicMovieRemarkDetail(remarkId: String, currPage: Int, pageSize: Int)
    // 电影评论
    case addMovieRemark(remark: String, movieId: String)
    // 对电影评论回复
    case addMovieReply(remarkId: String, toId: String, replyMsg: String, replyType: String)
    
}
extension TopicApi: TargetType {
    var path: String {
        switch self {
        case .delMovieILike: return Configs.Network.Topic.delMovieILike
        case .recentSearchVideo: return Configs.Network.Topic.recentSearchVideo
        case .delSearchVideo: return Configs.Network.Topic.delSearchVideo
        case .addMovieILike: return Configs.Network.Topic.addMovieILike
        case .topicVideoRecommend: return Configs.Network.Topic.topicVideoRecommend
        case .topicMovieList: return Configs.Network.Topic.topicMovieList
        case .delAllSearch: return Configs.Network.Topic.batchDelSearch
        case .searchTopicMovie: return Configs.Network.Topic.searchTopicVideo
        case .topicWatchMovie: return Configs.Network.Topic.topicWatchMovie
        case .topicMovieRemarkDetail: return Configs.Network.Topic.topicMovieRemarkDetail
        case .addMovieRemark: return Configs.Network.Topic.addMovieRemark
        case .addMovieReply: return Configs.Network.Topic.addMovieReply
        }
    }
    var sampleData: Data {
        return Data()
    }
    var task: Task {
        var params: [String: Any] = [:]
        switch self {
        case let .delMovieILike(movieId, remarkId):
            if let movieId = movieId {
                params["movieId"] = movieId
            }
            if let remarkId = remarkId {
                params["remarkId"] = remarkId
            }
            
        case let .delSearchVideo(searchId):
            params["searchId"] = searchId
        case let .addMovieILike(movieId, remarkId, likeType):
            if let movieId = movieId {
                params["movieId"] = movieId
            }
            if let remarkId = remarkId {
                params["remarkId"] = remarkId
            }
            params["likeType"] = likeType.rawValue
        case let .topicMovieList(columnId, page, pageSize):
            params["columnId"] = columnId
            params["currPage"] = page
            params["pageSize"] = pageSize
        case let .searchTopicMovie(keyWord, currPage, pageSize):
            params["currPage"] = currPage
            params["pageSize"] = pageSize
            params["keyWord"] = keyWord
        case let .topicWatchMovie(movieId, columnId, currPage, pageSize):
            params["movieId"] = movieId
            params["columnId"] = columnId
            params["currPage"] = currPage
            params["pageSize"] = pageSize
        case let .topicMovieRemarkDetail(remarkId, currPage, pageSize):
            params["remarkId"] = remarkId
            params["currPage"] = currPage
            params["pageSize"] = pageSize
        case let .addMovieRemark(remark, movieId):
            params["remark"] = remark
            params["movieId"] = movieId
        case let .addMovieReply(remarkId, toId, replyMsg, replyType):
            params["remarkId"] = remarkId
            params["toId"] = toId
            params["replyMsg"] = replyMsg
            params["replyType"] = replyType
        case .recentSearchVideo,
             .topicVideoRecommend,
             .delAllSearch: break
        
        }
        // 全局处理userid参数
        params["userId"] = LocalUserInfo.share.userId ?? ""
        params = customGenerate(params)
        return .requestParameters(parameters: params, encoding: URLEncoding.default)
    }
}

extension TopicApi: NetworkCachable {
    var cachePolicy: URLRequest.CachePolicy {
        switch self {
        case .topicVideoRecommend:
            // 如果使用了HTTP缓存策略，可能无法感知本地缓存需要更新
            return .returnCacheDataElseLoad
        default: return .useProtocolCachePolicy
        }
    }
}

extension TopicApi {
    enum LikeType: Int {
        case movie
        case comment
    }
}

