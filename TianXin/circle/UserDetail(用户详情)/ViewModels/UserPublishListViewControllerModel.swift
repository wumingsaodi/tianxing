//
//  UserPublishListViewControllerModel.swift
//  TianXin
//
//  Created by pretty on 10/19/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class UserPublishListViewControllerModel: NSObject, ViewModelType {
    let userId: String
    let dataType: UserPublishListViewController.DataType
    init(userId: String, dataType: UserPublishListViewController.DataType) {
        self.userId = userId
        self.dataType = dataType
    }
    
    var cachedWidths: [String: CGFloat] = [:]
    
    var page = 0
    var pageSize = 20
    let isHeaderLoding = ActivityIndicator()
    let isFooterLoading = ActivityIndicator()
    let isLoding = ActivityIndicator()
    let noMoreData = PublishSubject<Bool>()
    let error = ErrorTracker()
    let errMsg = PublishSubject<String>()
    
    lazy var provider = HttpProvider<SquareApi>.default
    
    // 点击点赞按钮
    let onLikeIssue = PublishSubject<(String, Bool)>()
    // 点击评论按钮
    let onTapComment = PublishSubject<String>()
    
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
    }
    
    struct Output {
        let items: Driver<[UserPublishIssueItemViewModel]>
        let onTapComment: Observable<String>
    }
    
    func transform(input: Input) -> Output {
        let items = BehaviorRelay<[UserPublishIssueItemViewModel]>(value: [])
        
        let transData = { [weak self] (issue: PublishIssue) -> UserPublishIssueItemViewModel in
            let model = UserPublishIssueItemViewModel(issue)
            guard let self = self else { return model }
            model.onLike.bind(to: self.onLikeIssue).disposed(by: self.rx.disposeBag)
            model.onComment.bind(to: self.onTapComment).disposed(by: self.rx.disposeBag)
            // 计算circle name宽度并缓存
            let names = (issue.joinRecommendList ?? []).compactMap{$0.recommendName}
            names.forEach { text in
                if self.cachedWidths[text] == nil {
                    let width = (text as NSString).boundingRect(with: .init(width: CGFloat.greatestFiniteMagnitude, height: 20),
                                                                options: .usesFontLeading,
                                                                attributes: [.font: UIFont.systemFont(ofSize: 12)],
                                                                context: nil).size.width
                    self.cachedWidths[text] = ceil(width)
                }
            }
            model.circleNameWidths.accept(self.cachedWidths.filter({names.contains($0.key)}))
            return model
        }
        
        // 下拉刷新
        input.headerRefresh.flatMapLatest({[weak self]() -> Observable<[PublishIssue]> in
            guard let self = self else { return Observable.just([])}
            self.page = 1
            let (api, keyPath) = self.getApi()
            return api.request(keyPath: keyPath, type: [PublishIssue].self, provider: self.provider)
                .trackError(self.error)
                .trackActivity(self.isHeaderLoding)
                .trackActivity(self.isLoding)
        }).subscribe(onNext: { value in
            items.accept(value.map(transData))
        }).disposed(by: rx.disposeBag)
        // 下拉加载更多
        input.footerRefresh.flatMapLatest({[weak self]() -> Observable<[PublishIssue]> in
            guard let self = self else { return Observable.just([])}
            self.page += 1
            let (api, keyPath) = self.getApi()
            return api.request(keyPath: keyPath, type: [PublishIssue].self, provider: self.provider)
                .trackActivity(self.isFooterLoading)
                .trackError(self.error)
        }).subscribe(onNext: { [weak self] value in
            guard let self = self else { return }
            if value.count < self.pageSize {
                self.noMoreData.onNext(true)
            }
            if value.isEmpty {
                self.page -= 1
            }
            items.accept(items.value + value.map(transData))
        }).disposed(by: rx.disposeBag)
        // 点赞帖子
        NotificationCenter.default.rx.notification(.IssueOnLike)
            .compactMap({$0.object as? [String: Any]})
            .map({($0["issueId"] as? String, $0["isLike"] as? Bool)})
            .asDriverOnErrorJustComplete()
            .drive(onNext: {[weak self](issueId, isLike) in
                guard let self = self else { return }
                var value = items.value
                if let index = value.firstIndex(where: {$0.item.issueId == issueId}) {
                    var item = value[index].item
                    item.isIssueLike = isLike ?? !item.isIssueLike
                    if item.isIssueLike {
                        item.issueLikeCount += 1
                    } else {
                        item.issueLikeCount -= 1
                    }
                    let model = UserPublishIssueItemViewModel(item)
                    model.onLike.bind(to: self.onLikeIssue).disposed(by: self.rx.disposeBag)
                    model.onComment.bind(to: self.onTapComment).disposed(by: self.rx.disposeBag)
                    value[index] = model
                    items.accept(value)
                }
            }).disposed(by: rx.disposeBag)
        onLikeIssue.asObservable()
            .flatMapLatest({[weak self] (issueId, isLiking) -> Observable<(String, JSON)> in
                let api: SquareApi
                if isLiking {
                    api = SquareApi.addUserLike(likeType: "0", issueId: issueId, remarkId: nil, replyId: nil, nickName: nil)
                } else {
                    api = SquareApi.delUserILike(issueId: issueId, remarkId: nil, replyId: nil)
                }
                guard let self = self else { return Observable.just((issueId, .null))}
                return api.request(provider: self.provider)
                    .map{(issueId, $0)}
                    .trackError(self.error)
                    .trackActivity(self.isLoding)
            }).subscribe(onNext: { [weak self] (issueId, json) in
                guard let self = self else { return }
                if json.code.string != "success" {
                    self.errMsg.onNext(json.message.string)
                    return
                }
                var value = items.value
                guard let index = value.firstIndex(where: {$0.item.issueId == issueId}) else { return }
                var issue = value[index].item
                if issue.isIssueLike {
                    issue.isIssueLike = false
                    issue.issueLikeCount = max(0, (issue.issueLikeCount ?? 0) - 1)
                } else {
                    issue.isIssueLike = true
                    issue.issueLikeCount = (issue.issueLikeCount ?? 0) + 1
                }
                let model = UserPublishIssueItemViewModel(issue)
                model.onLike.bind(to: self.onLikeIssue).disposed(by: self.rx.disposeBag)
                model.onComment.bind(to: self.onTapComment).disposed(by: self.rx.disposeBag)
                value[index] = model
                items.accept(value)
            }).disposed(by: rx.disposeBag)
        
        // 评论通知
        NotificationCenter.default.rx.notification(.CommentOnIssue)
            .compactMap({$0.object as? String})
            .asDriverOnErrorJustComplete()
            .drive(onNext: { issueId in
                if let index = items.value.firstIndex(where: {$0.item.issueId == issueId}) {
                    var values = items.value
                    let value = items.value[index]
                    value.replyNum.accept(value.replyNum.value + 1)
                    values[index] = value
                    items.accept(values)
                }
            })
            .disposed(by: rx.disposeBag)
        
        return Output(
            items: items.asDriver(),
            onTapComment: onTapComment.asObservable()
        )
    }
    
    private func getApi() -> (SquareApi, String) {
        let api: SquareApi
        let keyPath: String
        switch dataType {
        case .发布:
            keyPath = "userPubIssueList"
            api = SquareApi.checkUserPubIssueList(toId: self.userId, currPage: self.page, pageSize: self.pageSize)
        case .收藏:
            keyPath = "userCollectMessageList"
            api = SquareApi.checkUserCollectInfo(toId: self.userId, currPage: self.page, pageSize: self.pageSize)
        case .足迹:
            keyPath = "userTripMessageList"
            api = SquareApi.checkUserTripInfo(toId: self.userId, currPage: self.page, pageSize: self.pageSize)
        }
        return (api, keyPath)
    }
    
}
