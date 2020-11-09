//
//  PostingViewControllerModel.swift
//  TianXin
//
//  Created by pretty on 10/15/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


extension JoinRecommend {
    func toCircleItem() -> CircleItem {
        return CircleItem(recommendId: Int64(self.recommendId), recommendUserNum: 0, recommendTZNum: 0, recommendPic: self.recommendPic, recommendName: self.recommendName, recommendDesc: self.recommendDesc, isJoin: false )
    }
}

class PostingViewControllerModel: NSObject, ViewModelType {
    enum FromType {
        case 圈子(circleId: String)
        case 广场
    }
    
    let fromType: FromType
    init(fromType: FromType) {
        self.fromType = fromType
    }
    
    var circleId: String? {
        return fromType.value
    }
    
    lazy private var provider = HttpProvider<SquareApi>.default
    let error = ErrorTracker()
    let isLoading = ActivityIndicator()
    let errMsg = PublishSubject<String>()
    let success = PublishSubject<Void>()
    
    struct Input {
        let postEvent: Observable<Issue>
    }
    struct Output {
        let circleItems: Driver<[AvatarSelectionCellViewModel]>
        let circleListHidden: Driver<Bool>
    }
    func transform(input: Input) -> Output {
        let circleItems = BehaviorRelay<[AvatarSelectionCellViewModel]>(value: [])
        let circleListHidden = BehaviorRelay<Bool>(value: fromType != .广场)
        // 请求我加入的圈子
        SquareApi.checkJoinList(toId: nil)
            .request(keyPath: "myJoinList", type: [CircleItem].self, provider: self.provider)
            .subscribe(onNext: { [weak self] items in
                guard let self = self else { return }
                circleListHidden.accept(!(self.fromType == .广场 && items.count > 0))
                circleItems.accept(items.map {AvatarSelectionCellViewModel($0)})
            }).disposed(by: rx.disposeBag)
        // 上传帖子
        input.postEvent
            // 上传图片 或 视频
            .flatMapLatest({ [weak self] issue -> Observable<(Issue, [String], String?)> in
                guard let self = self else { return Observable.just((issue, [], nil))}
                if !issue.images.isEmpty {
                    return NetWorkingHelper.rx.upload(images: issue.images)
                        .trackError(self.error).map {(issue, $0, nil)}
                        .trackActivity(self.isLoading)
                }
                if let url = issue.videoURL {
                    return NetWorkingHelper.rx.upload(videoAssetURL: url)
                        .trackError(self.error).map {(issue, [], $0)}
                        .trackActivity(self.isLoading)
                }
                return Observable.just((issue, [], ""))
            }).flatMapLatest({ [weak self] (issue, imagesUrls, videoUrl) -> Observable<JSON> in
                guard let self = self else { return Observable.just(.null)}
                // 已选择发布的圈子
                let selectedCircleItems = circleItems.value.filter({$0.isSelected.value}).map({"\($0.item.recommendId)"})
                // 如果是从圈子发布的帖子
                var circleList = selectedCircleItems
                if let circleId = self.circleId, !circleList.contains(circleId) {
                    circleList.append(circleId)
                }
                var imagesStr: String?
                if !imagesUrls.isEmpty {
                    imagesStr = imagesUrls.joined(separator: ",")
                }
                return SquareApi.addIssue(remark: issue.remark,
                                          isSquare: issue.isSquare,
                                          recommendId: circleList.joined(separator: ","),
                                          issuePic: imagesStr,
                                          issueVideo: videoUrl).request(provider: self.provider)
                    .trackError(self.error)
                    .trackActivity(self.isLoading)
            }).subscribe(onNext: { [weak self] json in
                guard let self = self else { return }
                if json.code.string != "success" {
                    self.errMsg.onNext(json.message.string)
                } else {
                    self.success.onNext(())
                }
            }).disposed(by: rx.disposeBag)
        
       return Output(
        circleItems: circleItems.asDriver(),
        circleListHidden: circleListHidden.asDriver()
       )
    }
}

extension PostingViewControllerModel.FromType {
    var value: String? {
        switch self {
        case .圈子(let circleId): return circleId
        default: return nil
        }
    }
    static func == (lhs: PostingViewControllerModel.FromType, rhs: PostingViewControllerModel.FromType) -> Bool {
        switch (lhs, rhs) {
        case (.广场, .广场): return true
        case (.圈子, .圈子): return true
        default: return false
        }
    }
    static func != (lhs: PostingViewControllerModel.FromType, rhs: PostingViewControllerModel.FromType) -> Bool {
        return !(lhs == rhs)
    }
}
 
extension PostingViewControllerModel {
    struct Issue {
        var remark: String // 发布内容
        var images: [UIImage] = [] // 发布图片
        var videoURL: URL?
        var isSquare: Bool = true // 发布到广场
    }
}
