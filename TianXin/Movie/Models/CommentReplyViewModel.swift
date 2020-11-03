//
//  CommentReplyViewModel.swift
//  TianXin
//
//  Created by pretty on 10/13/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

struct CommentReplyViewModel {
    let username = BehaviorRelay<String?>(value: nil)
    let avatar = BehaviorRelay<String?>(value: nil)
    let time = BehaviorRelay<String?>(value: nil)
    let content = BehaviorRelay<String?>(value: nil)
    let likeCount = BehaviorRelay<Int>(value: 0)
    let replyCount = BehaviorRelay<Int>(value: 0)
    
    // 第一个参数是id，第二个参数为【喜欢】或【取消喜欢】
    let onLike = PublishSubject<(Int, Bool)>()
    
    let reply: CommentReply
    init(_ reply: CommentReply) {
        self.reply = reply
        username.accept(reply.replyName)
        avatar.accept(reply.replyUserLogo)
        time.accept(reply.createTime)
        content.accept(reply.replyMessage)
        likeCount.accept(0)
        replyCount.accept(0)
    }
}
