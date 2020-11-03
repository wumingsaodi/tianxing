//
//  UserPublishIssueItemViewModel.swift
//  TianXin
//
//  Created by pretty on 10/19/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct UserPublishIssueItemViewModel {
    let avatarUrl = BehaviorRelay<String?>(value: nil)
    let name = BehaviorRelay<String?>(value: nil)
    let content = BehaviorRelay<String?>(value: nil)
    let imageUrls = BehaviorRelay<[String]>(value: [])
    let videoUrl = BehaviorRelay<String?>(value: nil)
    let time = BehaviorRelay<String?>(value: nil)
    let likeNum = BehaviorRelay<Int>(value: 0)
    let replyNum = BehaviorRelay<Int>(value: 0)
    let isLiked = BehaviorRelay<Bool>(value: false)
    let circles = BehaviorRelay<[CircleItem]>(value: [])
    let circleNameWidths = BehaviorRelay<[String: CGFloat]>(value: [:])
    
    let onLike = PublishSubject<(String, Bool)>()
    let onComment = PublishSubject<String>()
    
    let item: PublishIssue
    init(_ item: PublishIssue) {
        self.item = item
        avatarUrl.accept(item.userLogo)
        name.accept(item.nickName ?? item.userName)
        content.accept(item.issueContent)
        imageUrls.accept(item.issuePic ?? [])
        time.accept(item.createTime)
        likeNum.accept(item.issueLikeCount ?? 0)
        replyNum.accept(item.squareRemarkCount ?? 0)
        isLiked.accept(item.isIssueLike)
        videoUrl.accept(item.issueVideo)
        circles.accept(item.joinRecommendList ?? [])
    }
}
