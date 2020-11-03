//
//  TopicMovieListCellViewModel.swift
//  TianXin
//
//  Created by pretty on 10/8/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TopicMovieListCellViewModel {
    let title = BehaviorRelay<String?>(value: nil)
    let cover = BehaviorRelay<String?>(value: nil)
    let visitCount = BehaviorRelay<Int>(value: 0)
    let videoLikeCount = BehaviorRelay<Int>(value: 0)
    let isLike = BehaviorRelay<Bool>(value: false)
    
    let movie: TopicMovie
    init(movie: TopicMovie) {
        self.movie = movie
        title.accept(movie.title)
        cover.accept(movie.cover)
        visitCount.accept(movie.visitCount ?? 0)
        videoLikeCount.accept(movie.videoLikeCount ?? 0)
        isLike.accept(movie.isLike == 1)
    }
}

