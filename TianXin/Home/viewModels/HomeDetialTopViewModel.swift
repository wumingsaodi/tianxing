//
//  HomeDetialTopViewModel.swift
//  TianXin
//
//  Created by SDS on 2020/11/7.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
///点赞视频
let api_addMyLoveMovie = "/gl/user/addMyLove"
///电影收藏
let api_addCollection = "/gl/user/addLike"
class HomeDetialTopViewModel: NSObject,ViewModelType {
    struct Input {
       var loveobservale:Observable<HomedetailModel>
       var collectObservale:Observable<HomedetailModel>
    }
    struct Output  {
        var loveSelected:Driver<HomedetailModel>
        var collectSelected:Driver<HomedetailModel>
    }
    func transform(input: Input) -> Output {
        let  loveModel = PublishSubject<HomedetailModel>()
        let collectModel = PublishSubject<HomedetailModel>()
        
        input.loveobservale
            .flatMapLatest({ model -> Observable<HomedetailModel> in
                return  NetWorkingHelper.rx
                    .normalPost(url: api_addMyLoveMovie, pramas: ["movieId":model.movie.id]).map({_ in return model}).asObservable()
            }).subscribe(onNext: { model in
                model.isMovLike = !model.isMovLike
                loveModel.onNext(model)
            }).disposed(by: rx.disposeBag)
        ///
        input.collectObservale.flatMapLatest { (model) -> Observable<HomedetailModel> in
            return NetWorkingHelper.rx.normalPost(url: api_addCollection, pramas: ["movieId":model.movie.id,"isTopic":0,"isCollect":model.ilike ? 1 : 0]).map({_ in return model}).asObservable()
        }.subscribe(onNext: { model in
            model.ilike = !model.ilike
            collectModel.onNext(model)
        }).disposed(by: rx.disposeBag)
        
        let out = Output.init(loveSelected: loveModel.asDriver(onErrorJustReturn: HomedetailModel()), collectSelected: collectModel.asDriver(onErrorJustReturn: HomedetailModel()))
        return  out
    }
}
