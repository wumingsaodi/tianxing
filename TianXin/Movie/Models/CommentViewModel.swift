//
//  CommentViewModel.swift
//  TianXin
//
//  Created by pretty on 10/12/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct CommentViewModel {
    let username = BehaviorRelay<String?>(value: nil)
    let avatar = BehaviorRelay<String?>(value: nil)
    let time = BehaviorRelay<String?>(value: nil)
    let content = BehaviorRelay<String?>(value: nil)
    let likeCount = BehaviorRelay<Int>(value: 0)
    let replyCount = BehaviorRelay<Int>(value: 0)
    let isLike = BehaviorRelay<Bool>(value: false)
    
    let onLike = PublishSubject<(Int, Bool)>()
    
    let comment: Comment
    init(_ comment: Comment) {
        self.comment = comment
        username.accept(comment.nickName ?? comment.userName)
        avatar.accept(comment.userLogo)
        time.accept(comment.createTime)
        content.accept(comment.remark)
        likeCount.accept(comment.movieRemarkLikeNum)
        replyCount.accept(comment.topicMovieReplyNum)
        isLike.accept(comment.isTopicRmkLike == 1)
    }
}
