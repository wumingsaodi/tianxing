//
//  TaskFirstHeadViewModel.swift
//  TianXin
//
//  Created by SDS on 2020/10/27.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SignModel: BaseModel {
   var yuan = 0
   var signCount = 0
   var title = ""
   var kcoin = 5
    var  todayIsSign =  false
    var  coin =  0
    var allCount = 0
}

class TaskFirstHeadViewModel: NSObject, ViewModelType {
    let relaod = PublishSubject<Void>()
    struct Input { // event
      let  getData:Observable<Void>
    let checkIn: Observable<Void>
        // events
    }
    struct Output {
        let model: Driver<SignModel>
    }
    func transform(input: Input) -> Output {
        let rxmodel = BehaviorRelay<SignModel?>(value: nil)
        Observable.of(relaod, input.getData).merge().flatMapLatest({() -> Observable<[String: Any]> in
            return NetWorkingHelper.rx.normalPost(url: "/gl/taskcenter/getTaskSign", pramas: [:]).asObservable()
        }).subscribe { dict in
            guard let dataDict = dict["data"] as? [String:Any], let model = SignModel.deserialize(from: dataDict)else{
                return
            }
            rxmodel.accept(model)
        } onError: { error in
            
        }.disposed(by: rx.disposeBag)
        
        input.checkIn.flatMapLatest({() -> Observable<[String:Any]> in
            return NetWorkingHelper.rx.normalPost(url: "/gl/user/sign", pramas: [:]).asObservable()
        }).subscribe {[weak self] (dict) in
            self?.relaod.onNext(())
        }.disposed(by: rx.disposeBag)


        return Output(
            model: rxmodel.asDriver().filterNil()
        )
    }
}
