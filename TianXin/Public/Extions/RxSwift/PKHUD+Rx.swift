//
//  PKHUD+Rx.swift
//  TianXin
//
//  Created by pretty on 10/15/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import PKHUD

extension Reactive where Base: UIView {
    var hudShown: Binder<Bool> {
        return Binder<Bool>(self.base) {
            _, shown in
            if shown {
                HUD.show(.progress)
            } else {
                HUD.hide()
            }
        }
    }
    var errorMsg: Binder<String> {
        return Binder<String>(self.base) {
            _, msg in
            // 延迟0.1s执行，防止progress hide
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                HUD.flash(.labeledError(title: nil, subtitle: msg), delay: 1.5)
            }
        }
    }
    var message: Binder<String> {
        return Binder<String>(self.base) {
            _, msg in
            HUD.flash(.label(msg))
        }
    }
}
