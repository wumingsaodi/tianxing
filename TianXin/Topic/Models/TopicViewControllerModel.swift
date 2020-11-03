//
//  TopicViewControllerModel.swift
//  TianXin
//
//  Created by pretty on 10/7/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

class TopicViewControllerModel: NSObject, ViewModelType {
    let headerLoading = ActivityIndicator()
    struct Input {
        let headerRefresh: Observable<Void>
        let selection: Driver<TopicViewCellViewModel>
    }
    struct Output {
        let items: Driver<[TopicViewCellViewModel]>
        let selected: Driver<TopicViewCellViewModel>
    }
    func transform(input: Input) -> Output {
        let provider = HttpProvider<TopicApi>.default
        let items = BehaviorRelay<[TopicViewCellViewModel]>(value: [])
        input.headerRefresh.flatMapLatest({[weak self]() -> Observable<[Topic]> in
            guard let self = self else { return Observable.just([]) }
            return TopicApi.topicVideoRecommend
                .request(keyPath: "topicRecommendList", type: [Topic].self, provider: provider)
                .catchErrorJustReturn([])
                .trackActivity(self.headerLoading)
        }).subscribe(onNext: { topics in
            items.accept(topics.map {TopicViewCellViewModel(with: $0)})
        }).disposed(by: rx.disposeBag)
        return Output(
            items: items.asDriver(),
            selected: input.selection
        )
    }
}
