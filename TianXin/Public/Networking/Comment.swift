//
//  Comment.swift
//  TianXin
//
//  Created by pretty on 10/12/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation

// 评论
struct Comment: Codable {
    var remarkId: Int
    var userId: Int
    var userLogo: String?
    var userName: String?
    var remark: String?
    var createTime: String?
    var topicMovieReplyNum: Int
    var movieRemarkLikeNum: Int
    var isTopicRmkLike: Int?
}

struct CommentReply: Codable {
    var replyId: Int
    var userId: Int
    var replyType: Int
    var userName: String?
    var userLogo: String?
    var replyName: String?
    var replyUserLogo: String?
    var replyMessage: String?
    var remarkTime: String?
    var toId: Int
    var createTime: String?
}

// 接口真尼玛不规范!!!!!!!
struct CommentReplyResp {
    var movieRemarkLikeNum: Int
    var topicMovieRemarkReply: [CommentReply]
    var isAttention: Int?
    
    enum CodingKeys: String, CodingKey {
        case movieRemarkLikeNum
        case topicMovieRemarkReply
        case topicMovieRemark
    }
    enum TopicMovieRemarkKeys: String, CodingKey {
        case isAttention
    }
}

extension CommentReplyResp: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        movieRemarkLikeNum = try values.decode(Int.self, forKey: .movieRemarkLikeNum)
        topicMovieRemarkReply = try values.decode([CommentReply].self, forKey: .topicMovieRemarkReply)
        var topicMovieRemark = try values.nestedUnkeyedContainer(forKey: .topicMovieRemark)
        isAttention = try topicMovieRemark.decode(Int?.self)
    }
}

extension CommentReplyResp: Encodable {
    func encode(to encoder: Encoder) throws {}
}
