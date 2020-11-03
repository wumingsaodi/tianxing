//
//  MovieFavoritesViewControllerModel.swift
//  TianXin
//
//  Created by pretty on 10/9/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MovieFavoritesViewControllerModel: NSObject, ViewModelType {
    var page = 0
    var pageSize = 20
    
    let headerLoading = ActivityIndicator()
    let footerLoading = ActivityIndicator()
    let error = ErrorTracker()
    
    lazy var provider = HttpProvider<UserApi>.default
    
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let isEditing: Driver<Bool>
        let selectAll: Driver<Bool>
        let onDelete: Observable<Void>
    }
    struct Output {
        let items: Driver<[MovieFavoritesCellViewModel]>
        
    }
    func transform(input: Input) -> Output {
        let items = BehaviorRelay<[MovieFavoritesCellViewModel]>(value: [])
        input.headerRefresh.flatMapLatest({ [weak self] () -> Observable<[TopicMovie?]> in
            guard let self = self else { return Observable.just([]) }
            self.page = 1
            return UserApi.movieFavorites(currPage: self.page, pageSize: self.pageSize)
                .request(keyPath: "topicVideoList", type: [TopicMovie?].self, provider: self.provider)
                .trackError(self.error)
                .trackActivity(self.headerLoading)
        }).subscribe(onNext: { movies in
            items.accept(movies.compactMap({$0}).map{ MovieFavoritesCellViewModel(movie: $0) })
        }, onError: { error in
            print("\(error)")
        }).disposed(by: rx.disposeBag)
        
        input.footerRefresh.flatMapLatest({ [weak self] () -> Observable<[TopicMovie]> in
            guard let self = self else { return Observable.just([]) }
            self.page += 1
            return UserApi.movieFavorites(currPage: self.page, pageSize: self.pageSize).request(keyPath: "topicVideoList", type: [TopicMovie].self, provider: self.provider).trackActivity(self.footerLoading)
        }).subscribe(onNext: { movies in
            if movies.isEmpty {
                self.page -= 1
            }
            items.accept(items.value + movies.map { MovieFavoritesCellViewModel(movie: $0) })
        }).disposed(by: rx.disposeBag)
        
        input.isEditing.drive(onNext: { editing in
            items.value.forEach { $0.isEditing.accept(editing) }
        }).disposed(by: rx.disposeBag)
        
        input.selectAll.drive(onNext: { isSelected in
            items.value.forEach { $0.isSelected.accept(isSelected) }
        }).disposed(by: rx.disposeBag)
        // 删除
        input.onDelete.flatMapLatest({() -> Observable<Bool> in
            return Observable.just(false)
        }).subscribe(onNext: { success in
            // TODO: - 暂时没这接口
        }).disposed(by: rx.disposeBag)
        
        return Output(
            items: items.asDriver()
        )
    }
}
