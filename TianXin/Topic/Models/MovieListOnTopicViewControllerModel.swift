//
//  MovieListOnTopicViewControllerModel.swift
//  TianXin
//
//  Created by pretty on 10/8/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import NSObject_Rx
import Moya

class MovieListOnTopicViewControllerModel: NSObject, ViewModelType {
    var page = 1
    var pageSize = 20
    
    let headerLoading = ActivityIndicator()
    
    let topic: BehaviorRelay<Topic>
    init(topic: Topic) {
        self.topic = BehaviorRelay<Topic>(value: topic)
    }
    
    struct Input {
        let headerRefresh: Observable<Void>
        let selection: Driver<TopicMovieListCellViewModel>
    }
    struct Output {
        let items: Driver<[TopicMovieListCellViewModel]>
        let selected: Driver<TopicMovieListCellViewModel>
        let loadDataState: BehaviorRelay<UIView.LoadDataState?>
    }
    func transform(input: Input) -> Output {
        let provider = HttpProvider<TopicApi>.default
        let items = BehaviorRelay<[TopicMovieListCellViewModel]>(value: [])
        let loadDataState = BehaviorRelay<UIView.LoadDataState?>(value: nil)
        
        input.headerRefresh.flatMapLatest ({ [weak self] () -> Observable<[TopicMovie]> in
            guard let self = self else { return Observable.just([]) }
            return TopicApi.topicMovieList(columnId: self.topic.value.id, page: self.page, pageSize: self.pageSize)
                .request(keyPath: "topicMovieList", type: [TopicMovie].self, provider: provider)
                .trackActivity(self.headerLoading)
        }).subscribe(onNext: { movies in
            if movies.isEmpty {
                loadDataState.accept(.empty)
            }
            items.accept(movies.map{TopicMovieListCellViewModel(movie: $0)})
        }).disposed(by: rx.disposeBag)
        return Output(
            items: items.asDriver(),
            selected: input.selection,
            loadDataState: loadDataState
        )
    }
}
