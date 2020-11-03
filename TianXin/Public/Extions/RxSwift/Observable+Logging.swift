//
//  Observable+Logging.swift
//  TianXin
//
//  Created by pretty on 10/8/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import RxSwift

extension Observable {
    func logError(prefix: String = "Observable Error: ") -> Observable<Element> {
        return self.do(onNext: nil,
                       onError: { (error) in
                        print("\(prefix)\(error)")
            },
                       onCompleted: nil,
                       onSubscribe: nil,
                       onDispose: nil)

    }

    func logServerError(message: String) -> Observable<Element> {
        return self.do(onNext: nil,
                       onError: { (error) in
                        print("\(message)")
                        print("Observable Error: \(error.localizedDescription). \n")
            },
                       onCompleted: nil,
                       onSubscribe: nil,
                       onDispose: nil)
    }

    func logNext() -> Observable<Element> {
        return self.do(onNext: { (element) in
                print("\(element)")
            },
                       onError: nil,
                       onCompleted: nil,
                       onSubscribe: nil,
                       onDispose: nil)

    }
}
