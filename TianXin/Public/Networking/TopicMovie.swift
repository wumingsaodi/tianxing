//
//  TopicMovie.swift
//  TianXin
//
//  Created by pretty on 10/8/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation

struct TopicMovie: Codable {
    var id: Int
    var title: String?
    var cover: String?
    var visitCount: Int?
    var videoLikeCount: Int?
    var remark: String?
    var cid: Int
    var isTopic: Int?
    var isLike: Int?
    var address: String?
    var createTime: String?
    
}
