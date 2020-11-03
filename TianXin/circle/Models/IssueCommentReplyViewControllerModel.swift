//
//  IssueCommentReplyViewControllerModel.swift
//  TianXin
//
//  Created by pretty on 10/20/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class IssueCommentReplyViewControllerModel: NSObject, ViewModelType {
    
    typealias ReplyInfo = (String, String, String, String)
    
    let headerLoading = ActivityIndicator()
    let error = ErrorTracker()
    let isLoding = ActivityIndicator()
    let errorMsg = PublishSubject<String>()
    let reload = PublishSubject<Void>()
    let noMoreData = PublishSubject<Bool>()
    private var page = 1
    private var pageSize = 20
    
    lazy var provider = HttpProvider<SquareApi>.default
    
    var replyInfo: ReplyInfo?
    
    let remarkId: String
    init(remarkId: String) {
        self.remarkId = remarkId
    }
    
    let tapUser = PublishSubject<String>()
    let onLikeReply = PublishSubject<(String, Bool)>()
    
    struct Input {
        let reload: Observable<Void>
        let footerRefresh: Observable<Void>
        // 依次为 toid、replyType、replyid、name
        let replyToUser: Observable<ReplyInfo>
        // 回复消息
        let onReply: Observable<String>
        // 点赞评论
        let onLike: Observable<Void>
        // 关注评论发表用户
        let onAttention: Observable<Void>
    }
    struct Output {
        let issueComment: Driver<IssueComment>
        let replyItems: Driver<[IssueReplyItemViewModel]>
        let issueRemkLikeCount: Driver<Int>
        let isRmkLike: Driver<Bool>
        let tapUser: Observable<String>
        let replyToUserName: Observable<String>
        let commentNum: Driver<Int>
    }
    func transform(input: Input) -> Output {
        let issueComment = BehaviorRelay<IssueComment?>(value: nil)
        let replyItems = BehaviorRelay<[IssueReplyItemViewModel]>(value: [])
        let issueRemkLikeCount = BehaviorRelay<Int>(value: 0)
        let isRmkLike = BehaviorRelay<Bool>(value: false)
        let commentNum = BehaviorRelay<Int>(value: 0)
        
        Observable.of(input.reload, reload).merge().flatMapLatest({[weak self]() -> Observable<JSON> in
            guard let self = self else { return Observable.just(.null)}
            self.page = 1
            return SquareApi.checkCircleUserReplyMessage(remarkId: self.remarkId, currPage: self.page, pageSize: self.pageSize)
                .request(provider: self.provider)
                .trackError(self.error)
                .trackActivity(self.headerLoading)
        }).subscribe(onNext: { [weak self] json in
            guard let self = self else { return }
            let code = json.code.string
            if code != "success" {
                self.errorMsg.onNext(json.message.string)
                return
            }
            // 评论点赞数
            issueRemkLikeCount.accept(json.issueRemkLikeCount.int)
            // 发布评论用户
            guard let remarkUserInfo = json.remarkUserInfo.array.first?.object,
                  let data = try? JSONSerialization.data(withJSONObject: remarkUserInfo, options: .fragmentsAllowed),
                  let comment = try? JSONDecoder().decode(IssueComment.self, from: data) else { return }
            commentNum.accept(comment.num ?? 0)
            // 评论是否喜欢
            isRmkLike.accept(comment.isRmkLike == 1)
            issueComment.accept(comment)
            // 回复列表
            self.noMoreData.onNext((comment.replyList?.count ?? 0) < self.pageSize)
            replyItems.accept((comment.replyList ?? []).map{ [weak self]ele in
                let model = IssueReplyItemViewModel(ele)
                guard let self = self else { return model }
                model.tapAvatar.bind(to: self.tapUser).disposed(by: self.rx.disposeBag)
                model.onLike.bind(to: self.onLikeReply).disposed(by: self.rx.disposeBag)
                return model
            })
        }).disposed(by: rx.disposeBag)
        // 上拉加载更多
        input.footerRefresh.flatMapLatest({[weak self] () -> Observable<JSON> in
            guard let self = self else { return Observable.just(.null)}
            self.page += 1
            return SquareApi.checkCircleUserReplyMessage(remarkId: self.remarkId, currPage: self.page, pageSize: self.pageSize)
                .request(provider: self.provider)
                .trackError(self.error)
                .trackActivity(self.headerLoading)
        }).subscribe(onNext: { [weak self] json in
            guard let self = self else { return }
            let code = json.code.string
            if code != "success" {
                self.errorMsg.onNext(json.message.string)
                return
            }
            // 发布评论用户
            guard let remarkUserInfo = json.remarkUserInfo.array.first?.object,
                  let data = try? JSONSerialization.data(withJSONObject: remarkUserInfo, options: .fragmentsAllowed),
                  let comment = try? JSONDecoder().decode(IssueComment.self, from: data) else { return }
            // 回复列表
            self.noMoreData.onNext((comment.replyList?.count ?? 0) < self.pageSize)
            replyItems.accept(replyItems.value + (comment.replyList ?? []).map{ [weak self]ele in
                let model = IssueReplyItemViewModel(ele)
                guard let self = self else { return model }
                model.tapAvatar.bind(to: self.tapUser).disposed(by: self.rx.disposeBag)
                model.onLike.bind(to: self.onLikeReply).disposed(by: self.rx.disposeBag)
                return model
            })
        }).disposed(by: rx.disposeBag)
        // 点赞回复
        onLikeReply.flatMapLatest({[weak self] (replyId, isLiking) -> Observable<(String, JSON)> in
            guard let self = self else { return Observable.just((replyId, .null))}
            let api: SquareApi
            if isLiking {
                api = SquareApi.addUserLike(likeType: "2", issueId: nil, remarkId: nil, replyId: replyId, nickName: nil)
            } else {
                api = SquareApi.delUserILike(issueId: nil, remarkId: nil, replyId: replyId)
            }
            return api.request(provider: self.provider)
                .map {(replyId, $0)}
                .trackError(self.error)
                .trackActivity(self.isLoding)
        }).subscribe(onNext: { [weak self]replyId, json in
            guard let self = self else { return }
            if json.code.string != "success" {
                self.errorMsg.onNext(json.message.string)
                return
            }
            var value = replyItems.value
            let model = value.likedToggle(forid: replyId)
            model?.tapAvatar.bind(to: self.tapUser).disposed(by: self.rx.disposeBag)
            model?.onLike.bind(to: self.onLikeReply).disposed(by: self.rx.disposeBag)
            replyItems.accept(value)
        }).disposed(by: rx.disposeBag)
        // 点赞评论
        input.onLike.flatMapLatest({[weak self]() -> Observable<JSON> in
            guard let self = self else { return Observable.just(.null)}
            let api: SquareApi
            if isRmkLike.value {
                api = SquareApi.delUserILike(issueId: nil, remarkId: self.remarkId, replyId: nil)
            } else {
                api = SquareApi.addUserLike(likeType: "1", issueId: nil, remarkId: self.remarkId, replyId: nil, nickName: nil)
            }
            return api.request(provider: self.provider)
                .trackError(self.error)
                .trackActivity(self.isLoding)
        }).subscribe(onNext: { [weak self]json in
            guard let self = self else { return }
            if json.code.string != "success" {
                self.errorMsg.onNext(json.message.string)
            } else {
                isRmkLike.toggle()
                if isRmkLike.value {
                    issueRemkLikeCount.accept(issueRemkLikeCount.value + 1)
                } else {
                    issueRemkLikeCount.accept(issueRemkLikeCount.value - 1)
                }
                let obj: [String: Any] = [
                    "remarkId": self.remarkId,
                    "isLike": isRmkLike.value
                ]
                NotificationCenter.default.post(name: .RemarkOnLike, object: obj)
            }
        }).disposed(by: rx.disposeBag)
        // 评论
        input.replyToUser.subscribe(onNext: { [weak self] info in
            self?.replyInfo = info
        }).disposed(by: rx.disposeBag)
        input.onReply
            .filter({ _ in
                if LocalUserInfo.share.userInfo?.nickName.isEmpty ?? true {
                    // 未设置昵称，提醒用户设置昵称
                    SDSHUD.showError("请前往个人中心设置昵称")
                    return false
                }
                return true
            })
            .flatMapLatest({[weak self] text -> Observable<JSON> in
                guard let self = self,
                      let info = self.replyInfo else { return Observable.just(.null)}
                return SquareApi.addReply(
                    replyMsg: text,
                    toId: info.0,
                    replyType: info.1,
                    issueId: issueComment.value?.issueId,
                    remarkId: "\(issueComment.value?.remarkId ?? 0)",
                    replyId: info.2
                )
                    .request(provider: self.provider)
                    .trackError(self.error)
                    .trackActivity(self.isLoding)
            })
            .subscribe(onNext: { [weak self] json in
                guard let self = self else { return }
                if json.code.string != "success" {
                    self.errorMsg.onNext(json.message.string)
                    return
                }
                self.reload.onNext(())
            })
            .disposed(by: rx.disposeBag)
        // 关注用户
        input.onAttention.flatMapLatest({[weak self]() -> Observable<JSON> in
            guard let self = self else { return Observable.just(.null)}
            let api: SquareApi
            if issueComment.value?.isAttention == 1 {
                api = SquareApi.delMyAttention(toId: "\(issueComment.value?.userId ?? 0)")
            } else {
                api = SquareApi.addAttention(toId: "\(issueComment.value?.userId ?? 0)")
            }
            return api.request(provider: self.provider)
                .trackError(self.error)
                .trackActivity(self.isLoding)
        }).subscribe(onNext: { [weak self] json in
            guard let self = self else { return }
            if json.code.string != "success" {
                self.errorMsg.onNext(json.message.string)
            } else {
                var value = issueComment.value
                if value?.isAttention == 1 {
                    value?.isAttention = 0
                } else {
                    value?.isAttention = 1
                }
                issueComment.accept(value)
            }
        }).disposed(by: rx.disposeBag)
        
        return Output(
            issueComment: issueComment.asDriver().filterNil(),
            replyItems: replyItems.asDriver(),
            issueRemkLikeCount: issueRemkLikeCount.asDriver(),
            isRmkLike: isRmkLike.asDriver(),
            tapUser: tapUser.asObservable(),
            replyToUserName: input.replyToUser.map{$0.3},
            commentNum: commentNum.asDriver()
        )
    }
}

struct IssueReplyItemViewModel {
    let avatar = BehaviorRelay<String?>(value: nil)
    let name = BehaviorRelay<String?>(value: nil)
    let time = BehaviorRelay<String?>(value: nil)
    let content = BehaviorRelay<NSAttributedString?>(value: nil)
    let likeNum = BehaviorRelay<Int>(value: 0)
    let replyNum = BehaviorRelay<Int>(value: 0)
    let isLiked = BehaviorRelay<Bool>(value: false)
    
    let tapAvatar = PublishSubject<String>()
    let onLike = PublishSubject<(String, Bool)>()
    
    let issueReply: IssueReply
    init(_ issueReply: IssueReply) {
        self.issueReply = issueReply
        avatar.accept(issueReply.userLogo)
        name.accept(issueReply.nickName ?? issueReply.userName)
        time.accept(issueReply.createTime)
        isLiked.accept(issueReply.isRmkLike == 1)
        replyNum.accept(issueReply.issueRemkLikeCount ?? 0)
        likeNum.accept(issueReply.isLikeCount ?? 0)
    
        let replyMessage = issueReply.replyMessage ?? ""
        let replyToName = issueReply.replyNickName ?? issueReply.replyName ?? ""
        if issueReply.replyType == 1 {
            let attr = NSAttributedString(string: replyMessage, attributes: [
                .font: UIFont.systemFont(ofSize: 15),
                .foregroundColor: UIColor.black
            ])
            self.content.accept(attr)
        } else { // 二级回复
            let text = "回复 \(replyToName): \(replyMessage)"
            let attr = NSMutableAttributedString(string: text, attributes: [
                .font: UIFont.systemFont(ofSize: 15),
                .foregroundColor: UIColor.black
            ])
            if !replyToName.isEmpty {
                let nameRange = (text as NSString).range(of: replyToName)
                if nameRange.location != NSNotFound {
                    attr.addAttributes([
                        .foregroundColor: Configs.Theme.Color.primary
                    ], range: nameRange)
                }
            }
            self.content.accept(attr)
        }
    }
}

extension Array where Element == IssueReplyItemViewModel {
    mutating func likedToggle(forid id: String) -> Element? {
        guard let index = self.firstIndex(where: {"\($0.issueReply.replyId ?? 0)" == id}) else {
            return nil
        }
        var issueReply = self[index].issueReply
        if issueReply.isRmkLike == 1 {
            issueReply.isRmkLike = 0
            issueReply.isLikeCount = Swift.max(0, (issueReply.isLikeCount ?? 0) - 1)
        } else {
            issueReply.isRmkLike = 1
            issueReply.isLikeCount = (issueReply.isLikeCount ?? 0) + 1
            
        }
        let model = IssueReplyItemViewModel(issueReply)
        self[index] = model
        return model
    }
}
