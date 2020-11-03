//
//  UserDetailViewControllerModel.swift
//  TianXin
//
//  Created by pretty on 10/20/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class UserDetailViewControllerModel: NSObject, ViewModelType {
    
    let userId: String
    init(userId: String) {
        self.userId = userId
    }
    
    lazy var provider = HttpProvider<SquareApi>.default
    
    let isLoding = ActivityIndicator()
    let errMsg = PublishSubject<String>()
    
    struct Input {
        let attentionEvent: Observable<Bool>
    }
    struct Output {
        let userInfo: Driver<JSON>
        let isAttention: Driver<Bool>
        let userBackgroundPic: Driver<String?>
    }
    func transform(input: Input) -> Output {
        let isAttention = BehaviorRelay<Bool>(value: false)
        let userBackgroundPic = BehaviorRelay<String?>(value: nil)
        let userInfo = BehaviorRelay<JSON>(value: .null)
        
        SquareApi.checkIssueUserInfo(toId: userId)
            .request(provider: self.provider)
            .trackActivity(self.isLoding)
            .subscribe(onNext: { [weak self] json in
                guard let self = self else { return }
                if json.code.string != "success" {
                    self.errMsg.onNext(json.message.string)
                    return
                }
                isAttention.accept(json.isAttention.string == "1")
                userInfo.accept(json.issueUserInfoList.array.first ?? .null)
            })
            .disposed(by: rx.disposeBag)
        // 关注按钮操作
        input.attentionEvent.flatMapLatest({[weak self] isAttention -> Observable<JSON> in
            guard let self = self else { return Observable.just(.null) }
            let api: SquareApi
            if isAttention {
                api = SquareApi.addAttention(toId: self.userId)
            } else {
                api = SquareApi.delMyAttention(toId: self.userId)
            }
            return api.request(provider: self.provider)
                .trackActivity(self.isLoding)
        }).subscribe(onNext: { [weak self] json in
            guard let self = self else { return }
            if json.code.string != "success" {
                self.errMsg.onNext(json.message.string)
                return
            }
            isAttention.toggle()
        }).disposed(by: rx.disposeBag)
        // 关注用户通知
        NotificationCenter.default.rx.notification(.UserOnAttention)
            .compactMap{$0.object as? [String: Any]}
            .map{($0["userId"] as? Int, $0["isAttention"] as? Bool)}
            .asDriverOnErrorJustComplete()
            .drive(onNext: { [weak self] userId, isAttentionV in
                guard let self = self else { return }
                if "\(userId ?? 0)" == self.userId {
                    isAttention.accept(isAttentionV ?? !isAttention.value)
                }
            })
            .disposed(by: rx.disposeBag)
        
        return Output(
            userInfo: userInfo.asDriver(),
            isAttention: isAttention.asDriver(),
            userBackgroundPic: userBackgroundPic.asDriver()
        )
    }
}

/*
    "myExtensionCode": "01gZ8j",
   "nickName": "公良怀要",
   "otherExtensionCode": "578451",
   "userName": "test007",
   "userLogo": "https://tianxing-test1.s3.ap-east-1.amazonaws.com/db75deea05f24c3abcb3b40b23b6c641.jpg",
   "usColCount": 0,
   "careCount": 0,
   "tripCount": 0,
   "recommendCount": 4,
   "usReplyCount": 0,
   "beCaredCount": 3,
   "id": 456,
   "publishCount": 5
    "userBackgroundPic": null
 */
