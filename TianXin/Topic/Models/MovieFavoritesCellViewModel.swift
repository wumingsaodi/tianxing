//
//  MovieFavoritesCellViewModel.swift
//  TianXin
//
//  Created by pretty on 10/9/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class MovieFavoritesCellViewModel: TopicMovieListCellViewModel {
    let isEditing = BehaviorRelay<Bool>(value: false)
    let isSelected = BehaviorRelay<Bool>(value: false)

    override init(movie: TopicMovie) {
        super.init(movie: movie)
    }
}
