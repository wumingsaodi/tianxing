//
//  UserApi.swift
//  TianXin
//
//  Created by pretty on 10/12/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import Moya

enum GameType: String {
    case all
    case 体育 = "ty"
    case 电竞 = "dj"
    case 真人 = "zr"
    case 彩票 = "cp"
    case 棋牌 = "qp"
    case 电子 = "dz"
    case 捕鱼 = "by"
}

enum UserApi {
    // 收藏列表
    case movieFavorites(currPage: Int, pageSize: Int)
    // 收藏
    case addLike(movieId: String, isTopic: Bool, isCollect: Bool)
    // 包网获取包网所有场馆列表
    case queryGameByType(gameType: GameType)
    // 包网获取登录游戏场馆URL
    // gameCode => 小游戏编码
    case queryGameUrl(enName: String, gameCode: String?)
}

extension UserApi: NetworkCachable {
    var cachePolicy: URLRequest.CachePolicy {
        switch self {
        case .queryGameByType: return .returnCacheDataElseLoad
        default: return .useProtocolCachePolicy
        }
    }
}

extension UserApi: TargetType {
    
    var path: String {
        switch self {
        case .movieFavorites: return Configs.Network.User.movieFavorites
        case .addLike: return Configs.Network.User.addLike
        case .queryGameByType: return Configs.Network.User.queryGameByType
        case .queryGameUrl: return Configs.Network.User.queryGameUrl
        }
    }
    var task: Task {
        var params: [String: Any] = [:]
        switch self {
        case let .movieFavorites(currPage, pageSize):
            params["currPage"] = currPage
            params["pageSize"] = pageSize
        case let .addLike(movieId, isTopic, isCollect):
            params["movieId"] = movieId
            params["isTopic"] = isTopic ? "1" : "0"
            params["isCollect"] = isCollect ? "1" : "0"
        case let .queryGameByType(gameType):
            if case .all = gameType {
                break
            }
            params["gameType"] = gameType.rawValue
        case let .queryGameUrl(enName, gameCode):
            params["enName"] = enName
            params["isApp"] = true
            if let gameCode = gameCode {
                params["gameCode"] = gameCode
            }
        }
        // 全局处理userid参数
        params["userId"] = LocalUserInfo.share.userId ?? ""
        params = customGenerate(params)
        return .requestParameters(parameters: params, encoding: URLEncoding.default)
    }
    var sampleData: Data {
        return Data()
    }
}
