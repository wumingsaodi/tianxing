//
//  IssueDetailViewControllerModel.swift
//  TianXin
//
//  Created by pretty on 10/19/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class IssueDetailViewControllerModel: NSObject, ViewModelType {
    
    let issueId: String
    init(issueId: String) {
        self.issueId = issueId
    }
    
    lazy var provider = HttpProvider<SquareApi>.default
    let isLoading = ActivityIndicator()
    let error = ErrorTracker()
    let errMsg = PublishSubject<String>()
    let tapAvatar = PublishSubject<String>()
    let onLikeRemark = PublishSubject<(String, Bool)>()
    let reload = PublishSubject<Void>()
    let noMoreData = PublishSubject<Bool>()
    
    private var page = 1
    private var pageSize = 20
    
    struct Input {
        let refresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let onLike: Observable<Void>
        // 评论
        let onComment: Observable<String>
        // 关注
        let onAttention: Observable<Void>
        // 收藏
        let onFavorite: Observable<Void>
    }
    struct Output {
        let replys: Driver<[IssueCommentReplyItemViewModel]>
        let topReplys: Driver<[IssueCommentReplyItemViewModel]>
        let detail: Driver<IssueDetail>
        let isFavorited: Driver<Bool>
        let isLiked: Driver<Bool>
        let tapUser: Observable<String>
        let commentNum: Driver<Int>
    }
    func transform(input: Input) -> Output {
        let detail = BehaviorRelay<IssueDetail?>(value: nil)
        let replyItems = BehaviorRelay<[IssueCommentReplyItemViewModel]>(value: [])
        // 精选评论
        let topItems = BehaviorRelay<[IssueCommentReplyItemViewModel]>(value: [])
        let isCollect = BehaviorRelay<Bool>(value: false)
        let isIssueLike = BehaviorRelay<Bool>(value: false)
        let commentNum = BehaviorRelay<Int>(value: 0)
        
        Observable.of(input.refresh, reload).merge().flatMapLatest({[weak self]() -> Observable<JSON> in
            guard let self = self else { return Observable.just(.null)}
            self.page = 1
            return SquareApi.checkCareIssueDetail(issueId: self.issueId, currPage: self.page, pageSize: self.pageSize)
                .request(provider: self.provider)
                .trackError(self.error)
                .trackActivity(self.isLoading)
        }).subscribe(onNext: { [weak self]json in
            guard let self = self else { return }
            if json.code.string != "success" {
                self.errMsg.onNext(json.message.string)
                return
            }
            isCollect.accept(json.isCollect.int == 1)
            isIssueLike.accept(json.isIssueLike.int == 1)
            
            let detailIssueList = json.detailIssueList.array
            if detailIssueList.isEmpty {
                return
            }
            let transform = { [weak self](ele: IssueRemark) -> IssueCommentReplyItemViewModel in
                let model = IssueCommentReplyItemViewModel(ele)
                guard let self = self else { return model }
                model.tapAvatar.bind(to: self.tapAvatar).disposed(by: self.rx.disposeBag)
                model.onLike.bind(to: self.onLikeRemark).disposed(by: self.rx.disposeBag)
                return model
            }
            if let data = try? JSONSerialization.data(withJSONObject: detailIssueList[0].object, options: .fragmentsAllowed),
               let model = try? JSONDecoder().decode(IssueDetail.self, from: data) {
                detail.accept(model)
                commentNum.accept(model.squareRemarkCount ?? 0)
                replyItems.accept(model.remarkList.map(transform))
                self.noMoreData.onNext(model.remarkList.count < self.pageSize)
                // 精选评论
                topItems.accept(model.issueJxRemark.map(transform))
//                if model.remarkList.count <= 3 {
//                    return
//                }
//                let topReplys = model.remarkList.filter({$0.issueRemkLikeCount >= 10}).sorted { $0.issueRemkLikeCount > $1.issueRemkLikeCount }
//                topItems.accept(topReplys[0 ..< min(3, topReplys.count)].map(transform))
            }
        }).disposed(by: rx.disposeBag)
        
        input.footerRefresh.flatMapLatest({[weak self]() -> Observable<JSON> in
            guard let self = self else { return Observable.just(.null)}
            self.page += 1
            return SquareApi.checkCareIssueDetail(issueId: self.issueId, currPage: self.page, pageSize: self.pageSize)
                .request(provider: self.provider)
                .trackError(self.error)
                .trackActivity(self.isLoading)
        }).subscribe(onNext: {[weak self] json in
            guard let self = self else { return }
            if json.code.string != "success" {
                self.errMsg.onNext(json.message.string)
                return
            }
            let detailIssueList = json.detailIssueList.array
            if detailIssueList.isEmpty {
                return
            }
            let transform = { [weak self](ele: IssueRemark) -> IssueCommentReplyItemViewModel in
                let model = IssueCommentReplyItemViewModel(ele)
                guard let self = self else { return model }
                model.tapAvatar.bind(to: self.tapAvatar).disposed(by: self.rx.disposeBag)
                model.onLike.bind(to: self.onLikeRemark).disposed(by: self.rx.disposeBag)
                return model
            }
            if let data = try? JSONSerialization.data(withJSONObject: detailIssueList[0].object, options: .fragmentsAllowed),
               let model = try? JSONDecoder().decode(IssueDetail.self, from: data) {
                if model.remarkList.count < self.pageSize {
                    self.noMoreData.onNext(true)
                }
                replyItems.accept(replyItems.value + model.remarkList.map(transform))
            }
        }).disposed(by: rx.disposeBag)
        
        // 点击评论点赞按钮
        NotificationCenter.default.rx.notification(.RemarkOnLike)
            .compactMap({$0.object as? [String: Any]})
            .map({($0["remarkId"] as? String, $0["isLike"] as? Bool)})
            .subscribe(onNext: { remarkId, isLike in
                guard let remarkId = remarkId else { return }
                var value = replyItems.value
                var model = value.likedToggle(forid: remarkId)
                model?.tapAvatar.bind(to: self.tapAvatar).disposed(by: self.rx.disposeBag)
                model?.onLike.bind(to: self.onLikeRemark).disposed(by: self.rx.disposeBag)
                model?.onReply.bind(to: self.tapAvatar).disposed(by: self.rx.disposeBag)
                replyItems.accept(value)
                // 置顶评论
                value = topItems.value
                model = value.likedToggle(forid: remarkId)
                model?.tapAvatar.bind(to: self.tapAvatar).disposed(by: self.rx.disposeBag)
                model?.onLike.bind(to: self.onLikeRemark).disposed(by: self.rx.disposeBag)
                model?.onReply.bind(to: self.tapAvatar).disposed(by: self.rx.disposeBag)
                topItems.accept(value)
            })
            .disposed(by: rx.disposeBag)
        onLikeRemark.flatMapLatest({[weak self] (remarkId, isLiking) -> Observable<(String, JSON)> in
            guard let self = self else { return Observable.just((remarkId, .null))}
            let api: SquareApi
            if isLiking {
                api = SquareApi.addUserLike(likeType: "1", issueId: nil, remarkId: remarkId, replyId: nil, nickName: nil)
            } else {
                api = SquareApi.delUserILike(issueId: nil, remarkId: remarkId, replyId: nil)
            }
            return api.request(provider: self.provider)
                .map{(remarkId, $0)}
                .trackError(self.error)
                .trackActivity(self.isLoading)
        }).subscribe(onNext: { [weak self] remarkId, json in
            guard let self = self else { return }
            if json.code.string != "success" {
                self.errMsg.onNext(json.message.string)
                return
            }
            var value = replyItems.value
            var model = value.likedToggle(forid: remarkId)
            model?.tapAvatar.bind(to: self.tapAvatar).disposed(by: self.rx.disposeBag)
            model?.onLike.bind(to: self.onLikeRemark).disposed(by: self.rx.disposeBag)
            model?.onReply.bind(to: self.tapAvatar).disposed(by: self.rx.disposeBag)
            replyItems.accept(value)
            // 置顶评论
            value = topItems.value
            model = value.likedToggle(forid: remarkId)
            model?.tapAvatar.bind(to: self.tapAvatar).disposed(by: self.rx.disposeBag)
            model?.onLike.bind(to: self.onLikeRemark).disposed(by: self.rx.disposeBag)
            model?.onReply.bind(to: self.tapAvatar).disposed(by: self.rx.disposeBag)
            topItems.accept(value)
        }).disposed(by: rx.disposeBag)
        
        // 点赞帖子
        input.onLike.flatMapLatest({[weak self] () -> Observable<JSON> in
            guard let self = self else { return Observable.just(.null)}
            let api: SquareApi
            if !isIssueLike.value {
                api = SquareApi.addUserLike(likeType: "0", issueId: self.issueId, remarkId: nil, replyId: nil, nickName: nil)
            } else {
                api = SquareApi.delUserILike(issueId: self.issueId, remarkId: nil, replyId: nil)
            }
            return api.request(provider: self.provider)
                .trackError(self.error)
                .trackActivity(self.isLoading)
                
        }).subscribe(onNext: { [weak self] json in
            guard let self = self else { return }
            if json.code.string != "success" {
                self.errMsg.onNext(json.message.string)
                return
            }
            isIssueLike.toggle()
            guard var detailV = detail.value else {
                return
            }
            if isIssueLike.value {
                detailV.issueLikeCount += 1
            } else {
                detailV.issueLikeCount -= 1
            }
            detail.accept(detailV)
            // 由于项目没有数据层，不能做到诸如点赞数据的同步性，故采用通知方式，后期再改吧
            let obj: [String: Any] = [
                "issueId": self.issueId,
                "isLike": isIssueLike.value
            ]
            NotificationCenter.default.post(name: .IssueOnLike, object: obj)
        }).disposed(by: rx.disposeBag)
        // 评论帖子
        input.onComment
            .filter({ _ in
                if LocalUserInfo.share.userInfo?.nickName.isEmpty ?? true {
                    // 未设置昵称，提醒用户设置昵称
                    SDSHUD.showError("请前往个人中心设置昵称")
                    return false
                }
                return true
            })
            .flatMapLatest({[weak self] content -> Observable<JSON> in
            guard let self = self else { return Observable.just(.null)}
            return SquareApi.addRemark(issueId: self.issueId, remark: content, nickName: nil)
                .request(provider: self.provider)
                .trackError(self.error)
                .trackActivity(self.isLoading)
        }).subscribe(onNext: { [weak self] json in
            guard let self = self else { return }
            if json.code.string != "success" {
                self.errMsg.onNext(json.message.string)
                return
            }
            self.reload.onNext(())
            NotificationCenter.default.post(name: .CommentOnIssue, object: self.issueId)
        }).disposed(by: rx.disposeBag)
        // 关注发帖用户
        input.onAttention.flatMapLatest({[weak self]() -> Observable<JSON> in
            guard let self = self,
                  let detailV = detail.value else { return Observable.just(.null)}
            let api: SquareApi
            if detailV.isAttention {
                api = SquareApi.delMyAttention(toId: "\(detailV.userId)")
            } else {
                api = SquareApi.addAttention(toId: "\(detailV.userId)")
            }
            return api.request(provider: self.provider)
                .trackError(self.error)
                .trackActivity(self.isLoading)
        }).subscribe(onNext: { json in
            if json.code.string != "success" {
                self.errMsg.onNext(json.message.string)
            } else if var detailV = detail.value {
                detailV.isAttention.toggle()
                detail.accept(detailV)
                
                let obj: [String: Any] = [
                    "userId": detailV.userId,
                    "isAttention": detailV.isAttention
                ]
                NotificationCenter.default.post(name: .UserOnAttention, object: obj)
            }
        }).disposed(by: rx.disposeBag)
        // 收藏
        input.onFavorite.flatMapLatest({[weak self]() -> Observable<JSON> in
            guard let self = self else { return Observable.just(.null)}
            let api: SquareApi
            if isCollect.value {
                api = SquareApi.delMyCollect(issueId: self.issueId)
            } else {
                api = SquareApi.addMyCollect(issueId: self.issueId, nickName: nil)
            }
            return api.request(provider: self.provider)
                .trackError(self.error)
                .trackActivity(self.isLoading)
        }).subscribe(onNext: { [weak self]json in
            guard let self = self else { return }
            if json.code.string != "success" {
                self.errMsg.onNext(json.message.string)
            } else if var detailV = detail.value {
                isCollect.toggle()
                if isCollect.value {
                    detailV.collectCount += 1
                } else {
                    detailV.collectCount -= 1
                }
                detail.accept(detailV)
            }
        }).disposed(by: rx.disposeBag)
        
        return Output(
            replys: replyItems.asDriver(),
            topReplys: topItems.asDriver(),
            detail: detail.filterNil().asDriverOnErrorJustComplete(),
            isFavorited: isCollect.asDriver(),
            isLiked: isIssueLike.asDriver(),
            tapUser: tapAvatar.asObservable(),
            commentNum: commentNum.asDriver()
        )
    }
}

struct IssueCommentReplyItemViewModel {
    let avatar = BehaviorRelay<String?>(value: nil)
    let name = BehaviorRelay<String?>(value: nil)
    let time = BehaviorRelay<String?>(value: nil)
    let content = BehaviorRelay<String?>(value: nil)
    let likeCount = BehaviorRelay<Int>(value: 0)
    let replyCount = BehaviorRelay<Int>(value: 0)
    let isLiked = BehaviorRelay<Bool>(value: false)
    
    let tapAvatar = PublishSubject<String>()
    let onLike = PublishSubject<(String, Bool)>()
    let onReply = PublishSubject<String>()
    
    let issueRemark: IssueRemark
    init(_ issueRemark: IssueRemark) {
        self.issueRemark = issueRemark
        avatar.accept(issueRemark.userLogo)
        name.accept(issueRemark.nickName ?? issueRemark.userName)
        time.accept(issueRemark.createTime)
        content.accept(issueRemark.remark)
        likeCount.accept(issueRemark.issueRemkLikeCount)
        replyCount.accept(issueRemark.issueRemkReplyCount)
        isLiked.accept(issueRemark.isRmkLike)
    }
    
}

extension Array where Element == IssueCommentReplyItemViewModel {
    mutating func likedToggle(forid id: String) -> Element? {
        guard let index = self.firstIndex(where: {"\($0.issueRemark.remarkId)" == id}) else {
            return nil
        }
        var issueRemark = self[index].issueRemark
        if issueRemark.isRmkLike {
            issueRemark.isRmkLike = false
            issueRemark.issueRemkLikeCount -= 1
        } else {
            issueRemark.isRmkLike = true
            issueRemark.issueRemkLikeCount += 1
        }
        let model = IssueCommentReplyItemViewModel(issueRemark)
        self[index] = model
        return model
    }
}

