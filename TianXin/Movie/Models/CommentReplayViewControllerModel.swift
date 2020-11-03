//
//  CommentReplayViewControllerModel.swift
//  TianXin
//
//  Created by pretty on 10/13/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class CommentReplayViewControllerModel: NSObject, ViewModelType {
    let comment: Comment
    lazy var provider = HttpProvider<TopicApi>.default
    let reload = PublishSubject<Void>()
    private var page = 1
    private var pageSize = 20
    
    fileprivate var replyInfo: ReplyInfo?
    
    let noMoreData = PublishSubject<Bool>()
    
    init(comment: Comment) {
        self.comment = comment
    }
    
    let headerLoading = ActivityIndicator()
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let cellSelected: Observable<CommentReplyViewModel>
        let tapComment: Observable<Comment>
        let reply: Observable<String>
    }
    struct Output {
        let items: Driver<[CommentReplyViewModel]>
        let isAttention: Driver<Bool>
        let commentLikeCount: Driver<Int>
        let currentReplyTarget: Driver<String>
    }
    func transform(input: Input) -> Output {
        let items = BehaviorRelay<[CommentReplyViewModel]>(value: [])
        let isAttention = BehaviorRelay<Bool>(value: false)
        let commentLikeCount = BehaviorRelay<Int>(value: 0)
        let currentReplyTarget = BehaviorRelay<String>(value: comment.userName ?? "")
        // 拉取数据
        input.headerRefresh.flatMapLatest({[weak self]() -> Observable<JSON> in
            guard let self = self else { return Observable.just(.null) }
            self.page = 1
            return TopicApi.topicMovieRemarkDetail(remarkId: "\(self.comment.remarkId)", currPage: self.page, pageSize: self.pageSize)
                .request(provider: self.provider)
                .trackActivity(self.headerLoading)
        }).subscribe(onNext: { json in
            let topicMovieRemarkReply = json.topicMovieRemarkReply.object
            if let data = try? JSONSerialization.data(withJSONObject: topicMovieRemarkReply, options: .fragmentsAllowed),
               let replys = try? JSONDecoder().decode([CommentReply].self, from: data) {
                items.accept(replys.map {CommentReplyViewModel($0)})
                self.noMoreData.onNext(replys.count < self.pageSize)
            }
            let attention = json.topicMovieRemark.array.first?.isAttention.bool
            isAttention.accept(attention ?? false)
            
            let movieRemarkLikeNum = json.movieRemarkLikeNum.int
            commentLikeCount.accept(movieRemarkLikeNum)
            
        }).disposed(by: rx.disposeBag)
        // 上拉加载更多
        input.footerRefresh.flatMapLatest({[weak self]() -> Observable<JSON> in
            guard let self = self else { return Observable.just(.null) }
            self.page += 1
            return TopicApi.topicMovieRemarkDetail(remarkId: "\(self.comment.remarkId)", currPage: self.page, pageSize: self.pageSize)
                .request(provider: self.provider)
                .trackActivity(self.headerLoading)
        }).subscribe(onNext: { [weak self] json in
            guard let self = self else { return }
            let topicMovieRemarkReply = json.topicMovieRemarkReply.object
            if let data = try? JSONSerialization.data(withJSONObject: topicMovieRemarkReply, options: .fragmentsAllowed),
               let replys = try? JSONDecoder().decode([CommentReply].self, from: data) {
                items.accept(items.value + replys.map {CommentReplyViewModel($0)})
                self.noMoreData.onNext(replys.count < self.pageSize)
            }
        }).disposed(by: rx.disposeBag)
        // 点击评论
        input.cellSelected.subscribe(onNext: { [weak self] model in
            currentReplyTarget.accept(model.reply.replyName ?? "")
            self?.replyInfo = ReplyInfo(remarkId: "\(model.reply.replyId)", replyType: "2", toId: "\(model.reply.userId)")
        })
        .disposed(by: rx.disposeBag)
        
        input.tapComment.subscribe(onNext: { comment in
            currentReplyTarget.accept(comment.userName ?? "")
            self.replyInfo = ReplyInfo(remarkId: "\(comment.remarkId)", replyType: "1", toId: "\(comment.userId)")
        })
        .disposed(by: rx.disposeBag)
        // 回复评论
        input.reply
            .flatMapLatest({[weak self] text -> Observable<Bool> in
                if let replyInfo = self?.replyInfo, !text.isEmpty, let provider = self?.provider {
                    return TopicApi.addMovieReply(remarkId: replyInfo.remarkId, toId: replyInfo.toId, replyMsg: text, replyType: replyInfo.replyType)
                        .request(provider: provider)
                        .map { $0.code.string == "success" }
                } else {
                    return Observable.just(false)
                }
            })
            .subscribe(onNext: { [weak self] success in
                if success {
                    // 拉取数据
                    self?.reload.onNext(())
                }
            })
            .disposed(by: rx.disposeBag)
        
        return Output(
            items: items.asDriver(),
            isAttention: isAttention.asDriver(),
            commentLikeCount: commentLikeCount.asDriver(),
            currentReplyTarget: currentReplyTarget.asDriver()
        )
    }
}

extension CommentReplayViewControllerModel {
    struct ReplyInfo {
        var remarkId: String
        var replyType: String
        var toId: String
    }
}
