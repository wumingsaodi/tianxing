//
//  SearchResultsViewModel.swift
//  TianXin
//
//  Created by pretty on 10/10/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class SearchResultsViewModel: NSObject, ViewModelType {
    var page = 1
    var pageSize = 20
    var searchText = ""
    let footerLoading = ActivityIndicator()
    let provider = HttpProvider<TopicApi>.default
    
    struct Input {
        let searchText: Observable<String>
        let footerRefresh: Observable<Void>
    }
    struct Output {
        let items: Driver<[TopicMovieListCellViewModel]>
    }
    func transform(input: Input) -> Output {
        let items = BehaviorRelay<[TopicMovieListCellViewModel]>(value: [])
        
        input.searchText
            .flatMapLatest({ [weak self](text) -> Observable<[TopicMovie]> in
                guard let self = self else { return Observable.just([]) }
                if text.isEmpty { return Observable.just([]) }
                self.searchText = text
                self.page = 1
                return TopicApi.searchTopicMovie(keyWord: text, currPage: self.page, pageSize: self.pageSize)
                    .request(keyPath: "searchList", type: [TopicMovie].self, provider: self.provider)
                    .trackActivity(self.footerLoading)
            })
        .subscribe(onNext: { movies in
            items.accept(movies.map { TopicMovieListCellViewModel(movie: $0) })
        }).disposed(by: rx.disposeBag)
        
        input.footerRefresh.flatMapLatest ({ [weak self]() -> Observable<[TopicMovie]> in
            guard let self = self else { return Observable.just([]) }
            self.page += 1
            return TopicApi.searchTopicMovie(keyWord: self.searchText, currPage: self.page, pageSize: self.pageSize)
                .request(keyPath: "searchList", type: [TopicMovie].self, provider: self.provider)
                .trackActivity(self.footerLoading)
        }).subscribe(onNext: { movies in
            items.accept(items.value + movies.map {TopicMovieListCellViewModel(movie: $0)})
        }).disposed(by: rx.disposeBag)
        return Output(
            items: items.asDriver()
        )
    }
}
