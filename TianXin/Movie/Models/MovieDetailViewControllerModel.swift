//
//  MovieDetailViewControllerModel.swift
//  TianXin
//
//  Created by pretty on 10/12/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MovieDetailViewControllerModel: NSObject, ViewModelType {
    let movie: TopicMovie
    
    lazy var provider = HttpProvider<TopicApi>.default
    lazy var userProvider = HttpProvider<UserApi>.default
    
    let onLikeComment = PublishSubject<(Int, Bool)>()
    
    let isLoding = ActivityIndicator()
    let reload = PublishSubject<Void>()
    let noMoreData = PublishSubject<Bool>()
    var page = 1
    var pageSize = 20
    
    init(movie: TopicMovie) {
        self.movie = movie
    }
    
    struct Input {
        let sendComment: Observable<String>
        let reload: Observable<Void>
        let footerRefresh: Observable<Void>
        let likeMovie: Observable<Void>
        let favoriteMovie: Observable<Void>
    }
    struct Output {
        let recommends: Driver<[TopicMovieListCellViewModel]>
        let comments: Driver<[CommentViewModel]>
        let movie: Driver<MovieDetail>
        let isLikeMovie: Driver<Bool>
        let isFavoritedMovie: Driver<Bool>
        let keywords: Driver<[String]>
        let likeCount: Driver<Int>
    }
    func transform(input: Input) -> Output {
        let comments = BehaviorRelay<[CommentViewModel]>(value: [])
        let isLikeMovie = BehaviorRelay<Bool>(value: false)
        let isFavoritedMovie = BehaviorRelay<Bool>(value: false)
        let keywords = BehaviorRelay<[String]>(value: [])
        let movie = BehaviorRelay<MovieDetail?>(value: nil)
        let likeCount = BehaviorRelay<Int>(value: 0)
        let recommends = BehaviorRelay<[TopicMovieListCellViewModel]?>(value: nil)
        
        Observable.of(reload, input.reload).merge()
            .flatMapLatest({ [weak self]() -> Observable<MovieDetail> in
            guard let self = self else { return Observable.just(MovieDetail(isLike: nil, isCollect: 0, topicWatchMovieList: nil, movieWatch6List: nil)) }
            self.page = 1
            return TopicApi.topicWatchMovie(movieId: "\(self.movie.id)", columnId: "\(self.movie.cid)", page: self.page, pageSize: self.pageSize)
                .request(keyPath: "", type: MovieDetail.self, provider: self.provider)
                .trackActivity(self.isLoding)
        })
            .subscribe(onNext: { [weak self] model in
                movie.accept(model)
                guard let self = self else { return }
                recommends.accept(model.movieWatch6List?.map {TopicMovieListCellViewModel(movie: $0)} ?? [])
                let remarks = model.topicWatchMovieList?.first?.refMovieAllRemark ?? []
                self.noMoreData.onNext(remarks.count < self.pageSize)
                comments.accept(remarks.map { remark in
                    let viewModel = CommentViewModel(remark)
                    viewModel.onLike.bind(to: self.onLikeComment).disposed(by: self.rx.disposeBag)
                    return viewModel
                })
                isLikeMovie.accept(model.isLike == 1)
                isFavoritedMovie.accept(model.isCollect == 1)
                keywords.accept(model.topicWatchMovieList?.first?.keywords ?? [])
                likeCount.accept(model.topicWatchMovieList?.first?.videoLikeCount ?? 0)
            })
            .disposed(by: rx.disposeBag)
        // 下拉加载更多评论
        input.footerRefresh.flatMapLatest({[weak self]() -> Observable<MovieDetail> in
            guard let self = self else { return Observable.just(MovieDetail(isLike: nil, isCollect: 0, topicWatchMovieList: nil, movieWatch6List: nil)) }
            self.page += 1
            return TopicApi.topicWatchMovie(movieId: "\(self.movie.id)", columnId: "\(self.movie.cid)", page: self.page, pageSize: self.pageSize)
                .request(keyPath: "", type: MovieDetail.self, provider: self.provider)
                .trackActivity(self.isLoding)
        }).subscribe(onNext: { [weak self] model in
            guard let self = self else { return }
            let remarks = model.topicWatchMovieList?.first?.refMovieAllRemark ?? []
            self.noMoreData.onNext(remarks.count < self.pageSize)
            recommends.accept(model.movieWatch6List?.map {TopicMovieListCellViewModel(movie: $0)} ?? [])
            comments.accept(comments.value + remarks.map { remark in
                let viewModel = CommentViewModel(remark)
                viewModel.onLike.bind(to: self.onLikeComment).disposed(by: self.rx.disposeBag)
                return viewModel
            })
        }).disposed(by: rx.disposeBag)
        // 发送评论
        input.sendComment.flatMapLatest({ [weak self] text -> Observable<Bool> in
            guard let self = self else { return Observable.just(false) }
            return TopicApi.addMovieRemark(remark: text, movieId: "\(self.movie.id)").request(provider: self.provider)
                .map { $0.code.string == "success" }
        })
        .subscribe(onNext: { [weak self] success in
            if success {
                self?.reload.onNext(())
            }
        })
        .disposed(by: rx.disposeBag)
        // 点赞电影
        input.likeMovie.asObservable().flatMapLatest({ [weak self] () -> Observable<Bool> in
            guard let self = self else { return Observable.just(false)}
            let api: TopicApi
            if !isLikeMovie.value {
                api = TopicApi.addMovieILike(movieId: "\(self.movie.id)", remarkId: nil, likeType: .movie)
            } else {
                api = TopicApi.delMovieILike(movieId: "\(self.movie.id)", remarkId: nil)
            }
            return api.request(provider: self.provider).map { $0.code.string == "success"}
        })
        .subscribe(onNext: { [weak self] success in
            if success {
                isLikeMovie.toggle()
                if isLikeMovie.value {
                    likeCount.accept(likeCount.value + 1)
                } else {
                    likeCount.accept(max(likeCount.value - 1, 0))
                }
                guard let self = self else { return }
                let info: [String: Any] = [
                    "id": self.movie.id.toString(),
                    "isLike": isLikeMovie.value
                ]
                NotificationCenter.default.post(name: .LikeMovie, object: info)
//                self?.reload.onNext(())
            }
        })
        .disposed(by: rx.disposeBag)

        // 点赞评论
        onLikeComment.asObservable()
            .flatMapLatest({[weak self] (id, isLike) -> Observable<(Int, Bool)> in
                guard let self = self else { return Observable.just((id, false))}
                let api: TopicApi
                if isLike {
                    api = TopicApi.addMovieILike(movieId: nil, remarkId: "\(id)", likeType: .comment)
                } else {
                    api = TopicApi.delMovieILike(movieId: nil, remarkId: "\(id)")
                }
                return api.request(provider: self.provider).map { (id, $0.code.string == "success") }
            })
            .subscribe(onNext: { id, success in
                if success {
                    var value = comments.value
                    guard let index = value.firstIndex(where: { $0.comment.remarkId == id }) else {
                        return
                    }
                    let model = value[index]
                    model.isLike.toggle()
                    value[index] = model
                    comments.accept(value)
                }
            })
            .disposed(by: rx.disposeBag)
        // 电影收藏
        input.favoriteMovie.flatMapLatest({ [weak self] () -> Observable<Bool> in
            guard let self = self else { return Observable.just(false) }
            return UserApi.addLike(movieId: "\(self.movie.id)", isTopic: true, isCollect: !isFavoritedMovie.value)
                .request(provider: self.userProvider).map { $0.code.string == "success" }
        }).subscribe(onNext: { success in
            if success {
                isFavoritedMovie.toggle()
            }
        }).disposed(by: rx.disposeBag)
        
        return Output(
            recommends: recommends.asDriver().filterNil(),
            comments: comments.asDriver(),
            movie: movie.filterNil().asDriverOnErrorJustComplete(),
            isLikeMovie: isLikeMovie.asDriver(),
            isFavoritedMovie: isFavoritedMovie.asDriver(),
            keywords: keywords.asDriver(),
            likeCount: likeCount.asDriver()
        )
    }
}
