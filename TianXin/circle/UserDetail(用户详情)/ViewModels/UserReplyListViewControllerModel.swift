//
//  UserReplyListViewControllerModel.swift
//  TianXin
//
//  Created by pretty on 10/20/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class UserReplyListViewControllerModel: NSObject, ViewModelType {
    
    let userId: String
    init(userId: String) {
        self.userId = userId
    }
    
    var page = 0
    var pageSize = 20
    let isHeaderLoding = ActivityIndicator()
    let isFooterLoading = ActivityIndicator()
    let noMoreData = PublishSubject<Bool>()
    let error = ErrorTracker()
    
    lazy var provider = HttpProvider<SquareApi>.default
    
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
    }
    struct Output {
        let items: Driver<[UserReplyListCellViewModel]>
        let errMsg: Driver<String>
    }
    func transform(input: Input) -> Output {
        let errMsg = BehaviorRelay<String?>(value: nil)
        let items = BehaviorRelay<[UserReplyListCellViewModel]>(value: [])
        input.headerRefresh.flatMapLatest({[weak self]() -> Observable<JSON> in
            guard let self = self else { return Observable.just(.null)}
            self.page = 1
            return SquareApi.checkUserReplyMessage(toId: self.userId, currPage: self.page, pageSize: self.pageSize)
                .request(provider: self.provider)
                .trackError(self.error)
                .trackActivity(self.isHeaderLoding)
        }).subscribe(onNext: { [weak self] json in
            guard let self = self else { return }
            if json.code.string != "success" {
                errMsg.accept(json.message.string)
                return
            }
            let array = json.userReplyMessageList.array
            if array.count < self.pageSize {
                self.noMoreData.onNext(true)
            }
            items.accept(array.map{UserReplyListCellViewModel($0)})
        }).disposed(by: rx.disposeBag)
        
        // 下拉加载更多
        input.footerRefresh.flatMapLatest({[weak self]() -> Observable<JSON> in
            guard let self = self else { return Observable.just(.null)}
            self.page += 1
            return SquareApi.checkUserReplyMessage(toId: self.userId, currPage: self.page, pageSize: self.pageSize)
                .request(provider: self.provider)
                .trackError(self.error)
                .trackActivity(self.isHeaderLoding)
        }).subscribe(onNext: { [weak self] json in
            guard let self = self else { return }
            if json.code.string != "success" {
                errMsg.accept(json.message.string)
                return
            }
            let array = json.userReplyMessageList.array
            if array.count < self.pageSize {
                self.noMoreData.onNext(true)
            }
            items.accept(items.value + array.map({UserReplyListCellViewModel($0)}))
        }).disposed(by: rx.disposeBag)
        
        return Output(
            items: items.asDriver(),
            errMsg: errMsg.asDriver().filterNil()
        )
    }
}

struct UserReplyListCellViewModel {
    let avatar = BehaviorRelay<String?>(value: nil)
    let name = BehaviorRelay<String?>(value: nil)
    let content = BehaviorRelay<String?>(value: nil)
    let originContent = BehaviorRelay<String?>(value: nil)
    let time = BehaviorRelay<String?>(value: nil)
    let likeNum = BehaviorRelay<Int>(value: 0)
    let isLiked = BehaviorRelay<Bool>(value: false)
    let hasPhoto = BehaviorRelay<Bool>(value: false)
    let circles = BehaviorRelay<[JSON]>(value: [])
    
    let json: JSON
    init(_ json: JSON) {
        self.json = json
        avatar.accept(json.userLogo.string)
        var name = json.nickName.string
        if name.isEmpty {
            name = json.userName.string
        }
        self.name.accept(name)
        content.accept(json.remark.string)
        time.accept(json.createTime.string)
        likeNum.accept(json.issueLikeCount.int)
        isLiked.accept(json.isIssueLike.int == 1)
        originContent.accept(json.issueContent.string)
        hasPhoto.accept(!json.issuePic.array.isEmpty)
        circles.accept(json.joinRecommendList.array)
    }
}

/*
 {
       "toId": 468,
       "issueId": "Bs159e",
       "issueContent": "规划",
       "issueVideo": "",
       "nickName": "夹谷热孙",
       "remark": "fsdafsad",
       "userLogo": "https://tianxing-test1.s3.ap-east-1.amazonaws.com/db75deea05f24c3abcb3b40b23b6c641.jpg",
       "userName": "minglou1",
       "userId": 451,
       "squareRemarkCount": 1,
       "issuePic": "",
       "createTime": "2020-10-18 13:46:52",
       "replyMessage": "wwww",
       "replyId": null,
       "isIssueLike": null,
       "issueLikeCount": 2,
       "id": 110,
       "remarkId": 90,
       "remarkList": [
         {
           "toId": 451,
           "issueId": "Bs159e",
           "isRmkLike": [],
           "nickName": null,
           "loginIsReply": null,
           "remark": "fsdafsad",
           "userLogo": "https://tianxing-test1.s3.ap-east-1.amazonaws.com/db75deea05f24c3abcb3b40b23b6c641.jpg",
           "userName": "minglou1",
           "userId": 468,
           "createTime": "2020-10-18 13:11:14",
           "issueRemkLikeCount": 0,
           "issueRemkReplyCount": 1,
           "remarkId": 90
         }
       ]
     },
 */
