//
//  CircleHomeSearchLastViewModel.swift
//  TianXin
//
//  Created by SDS on 2020/11/2.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import HandyJSON
struct searchItem:HandyJSON {
var content = ""
var id = ""
}

///用户最近搜索
let api_circleRecentSearch = "/gl/square/recentSearch"
///全部删除最近搜索
let api_deleteAllSearch = "/gl/square/batchDelSearchSquares"
///单个删除最近搜索
 let api_deleteSingle =  "/gl/square/delSearchSquare"
class CircleHomeSearchLastViewModel: NSObject,ViewModelType {
    let reloadData = PublishSubject<Void>()
    struct Input {
     let  InStart:Driver<Void>
    let deleAll:Driver<Void>
        let deleSingle:Driver<String>
    }
    struct  Output {
        let searchRecentArr: Driver<[searchItem]>
//        let  dirverArr: Driver<[String]>
        
    }
    func transform(input: Input) -> Output {
        let searchArr = BehaviorRelay<[searchItem]>(value: [])
//        let  dirverArr = Driver<[String]>.just([])
        Observable.of(reloadData, input.InStart.asObservable()).merge()
            .flatMapLatest({ ()-> Observable<[String:Any]> in
            let obser = NetWorkingHelper.rx.normalPost(url: api_circleRecentSearch, pramas: [:])
            return obser.asObservable()
        }).subscribe(onNext: { dict in
            guard let  listArr = dict["recentSearchList"] as? [[String:Any]],let models =  [searchItem].deserialize(from: listArr) else{
                return
            }
            searchArr.accept(models.map({$0!}))
        }).disposed(by: rx.disposeBag)
        //
        input.deleSingle.asObservable().flatMapLatest({ (id)->Observable<[String:Any]> in
            let observa = NetWorkingHelper.rx.normalPost(url: api_deleteSingle, pramas: ["id":id])
            return observa.asObservable()
        }).subscribe(onNext: { [weak self] dict in
            self?.reloadData.onNext(())
        }).disposed(by: rx.disposeBag)
        input.deleAll.asObservable().flatMapLatest({ () -> Observable<[String:Any]> in
            return NetWorkingHelper.rx.normalPost(url: api_deleteAllSearch, pramas: [:]).asObservable()
        }).subscribe(onNext: { dict in
            searchArr.accept([])
        }).disposed(by: rx.disposeBag)
        return Output.init(searchRecentArr: searchArr.asDriver())
    }
}
