//
//  CircleHomeSearchVCViewModel.swift
//  TianXin
//
//  Created by SDS on 2020/10/31.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
///搜索按帖子内容
let  api_CircleSearch = "/gl/square/searchSquare"

class CircleHomeSearchVCViewModel: NSObject,ViewModelType {
    var currPage:Int = 1
    var pageSize:Int = 10
    var text = ""
    let noMoreData = PublishSubject<Bool>()
    
    struct  Input  {
        let  searchText:Observable<String?>
        let footerRefresh: Observable<Void>
    }
    struct  Output  {
        let searchmodels:Driver<[CircleHomeModel]>
    }
    func transform(input: Input) -> Output {
        let searchmods = BehaviorRelay<[CircleHomeModel]>(value: [])
        input.searchText.flatMapLatest {[weak self] (text) -> Observable<[String:Any]> in
            guard let self = self else{
                return  Observable.just([:])
            }
            if text.isEmpty {
                return Observable.just([:])
            }
            self.text = text ?? ""
            self.currPage = 1
            let obser = NetWorkingHelper.rx
                .normalPost(url: api_CircleSearch, pramas: ["keyWord":text as Any,"currPage":self.currPage,"pageSize":self.pageSize]).asObservable()
            return  obser
        }.subscribe { (dict) in
            guard let searchListArr = dict["searchList"] as? [Any],let models = [CircleHomeModel].deserialize(from: searchListArr)else{
                return
            }
            searchmods.accept(models.map({$0!}))
        } onError: { (eror) in
            
        }.disposed(by: rx.disposeBag)
        
        input.footerRefresh.flatMapLatest({[weak self]() -> Observable<[String: Any]> in
            guard let self = self else { return .just([:])}
            self.currPage += 1
            return NetWorkingHelper.rx
                .normalPost(url: api_CircleSearch, pramas: ["keyWord":self.text as Any,"currPage":self.currPage,"pageSize":self.pageSize]).asObservable()
        }).subscribe(onNext: { [weak self] dict in
            guard let self = self else { return }
            guard let searchListArr = dict["searchList"] as? [Any],let models = [CircleHomeModel].deserialize(from: searchListArr)else{
                return
            }
            self.noMoreData.onNext(models.count < self.pageSize)
            searchmods.accept(searchmods.value + models.map({$0!}))
        }).disposed(by: rx.disposeBag)

        return Output.init(searchmodels: searchmods.asDriver())
    }
    

}
