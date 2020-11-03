//
//  MJRefreshHeader+Rx.swift
//  TianXin
//
//  Created by pretty on 10/8/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import MJRefresh
import RxSwift
import RxCocoa

extension Reactive where Base: MJRefreshComponent {
    public var isAnimation: Binder<Bool> {
        return Binder(self.base) {
            refresher, active in
            if active {
                
            } else {
                refresher.endRefreshing()
            }
        }
    }
}

extension Reactive where Base: MJRefreshFooter {
    var noMoreData: Binder<Bool> {
        return Binder(self.base) {
            footer, noMoreData in
            if noMoreData {
                footer.endRefreshingWithNoMoreData()
            } else {
                footer.resetNoMoreData()
            }
        }
    }
}
