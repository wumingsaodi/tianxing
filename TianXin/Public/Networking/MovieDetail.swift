//
//  MovieDetail.swift
//  TianXin
//
//  Created by pretty on 10/12/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation

struct MovieDetail: Codable {
    var isLike: Int? // 是否喜欢
    var loginIsCollect: Int? // 是否收藏
    var topicWatchMovieList: [MovieInfo]?
    var movieWatch6List: [TopicMovie]?
}

struct MovieInfo: Codable {
    var id: Int
    var cid: Int
    var visitCount: Int
    var videoLikeCount: Int
    var address: String?
    var cover: String?
    var createTime: String?
    var isTopic: Int
    var remark: String?
    var title: String?
    var refMovieAllRemark: [Comment]?
    var keywords: [String]
}
// 电影收藏
struct MovieCollectItem: Codable {
    var userId: Int
    var movieId: String
}
