//
//  SDSAVView+Rx.swift
//  TianXin
//
//  Created by pretty on 10/26/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension Reactive where Base: SDSAVView {
    var videoURL: Binder<URL?> {
        return Binder<URL?>(self.base) {
            playerView, url in
            playerView.url = url
        }
    }
}
