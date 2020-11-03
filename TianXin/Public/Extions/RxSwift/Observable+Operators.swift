//
//  Observable+Operators.swift
//  TianXin
//
//  Created by pretty on 10/7/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


extension Observable where Element: Equatable {
    func ignore(value: Element) -> Observable<Element> {
        return filter { (selfE) -> Bool in
            return value != selfE
        }
    }
}

extension BehaviorRelay where Element == Bool {
    @discardableResult
    func toggle() -> BehaviorRelay<Element> {
        self.accept(!self.value)
        return self
    }
}

extension ObservableType {

    func catchErrorJustComplete() -> Observable<Element> {
        return catchError { _ in
            return Observable.empty()
        }
    }

    func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { error in
            assertionFailure("Error \(error)")
            return Driver.empty()
        }
    }

    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
}
