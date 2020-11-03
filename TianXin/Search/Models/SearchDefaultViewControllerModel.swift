//
//  SearchDefaultViewControllerModel.swift
//  TianXin
//
//  Created by pretty on 10/10/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SearchDefaultViewControllerModel: NSObject, ViewModelType {
    lazy var provider = HttpProvider<TopicApi>.default
    let refresh = PublishSubject<Void>()
    let onItemTap = PublishSubject<String>()
    let deleteItem = PublishSubject<Int>()
    
    struct Input {
        let deleteAll: Observable<Void>
        let modelSelected: Driver<RecentSearchCellViewModel>
    }
    struct Output {
        let items: Driver<[RecentSearchCellViewModel]>
    }
    func transform(input: Input) -> Output {
        input.modelSelected.map { $0.item.content }.filterNil().drive(onNext: { [weak self] text in
            self?.onItemTap.onNext(text)
        }).disposed(by: rx.disposeBag)
        let items = BehaviorRelay<[RecentSearchCellViewModel]>(value: [])
        deleteItem
            .flatMapLatest({ [weak self] id -> Observable<(Int, Bool)> in
                guard let self = self else { return Observable.just((id, false)) }
                if id == 0 {
                    return Observable.just((id, false))
                }
                return TopicApi.delSearchVideo(searchId: "\(id)").request(provider: self.provider).map {
                    (id, $0.code.string == "success")
                }
            })
            .subscribe(onNext: { (id, isDelete) in
            if !isDelete { return }
            var value = items.value
            if let index = value.firstIndex(where: { $0.item.id == id }) {
                value.remove(at: index)
            }
            items.accept(value)
        }).disposed(by: rx.disposeBag)
        input.deleteAll
            .flatMapLatest({ [weak self]() -> Observable<Bool> in
                guard let self = self else { return Observable.just(false) }
                return TopicApi.delAllSearch.request(provider: self.provider).map {
                    $0.code.string == "success"
                }
            })
            .subscribe(onNext: { isDelete in
            if !isDelete { return }
            items.accept([])
        }).disposed(by: rx.disposeBag)
        
        let reload = Observable.of(Observable.just(()), refresh).merge()
        reload.flatMapLatest ({ [weak self] () -> Observable<[SearchItem]> in
            guard let self = self else { return Observable.just([]) }
            return TopicApi.recentSearchVideo.request(keyPath: "searchVideoList", type: [SearchItem].self, provider: self.provider)
        })
        .subscribe(onNext: { value in
            // 去重
            let valueSet = Set(value)
            items.accept(valueSet.map { [weak self] ele in
                let model = RecentSearchCellViewModel(ele)
                guard let self = self else { return model }
                model.onDelete.bind(to: self.deleteItem).disposed(by: self.rx.disposeBag)
                return model
            })
        })
        .disposed(by: rx.disposeBag)
        return Output(
            items: items.asDriver()
        )
    }
}

