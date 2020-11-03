//
//  UITableView+RX.swift
//  TianXin
//
//  Created by pretty on 10/9/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import MJRefresh

extension Reactive where Base: UITableView {
    var allowsMultipleSelection: Binder<Bool> {
        return Binder<Bool>(self.base) {
            tableView, active in
            tableView.isEditing = active
            tableView.allowsMultipleSelection = active
            tableView.allowsMultipleSelectionDuringEditing = active
        }
    }
    var noMoreData: Binder<Bool> {
        return Binder<Bool>(self.base) {
            tableView, noMoreData in
            if noMoreData {
                tableView.mj_footer?.endRefreshingWithNoMoreData()
            } else {
                tableView.mj_footer?.resetNoMoreData()
            }
            
        }
    }
    var isLodingData: Binder<Bool> {
        return Binder(self.base) {
            tableView, active in
            if active {
                
            } else {
                tableView.mj_header?.endRefreshing()
            }
        }
    }
}
