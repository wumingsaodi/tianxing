//
//  UIScrollView+.swift
//  TianXin
//
//  Created by pretty on 10/8/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

extension Reactive where Base: UIView {
    var loadDataState: Binder<UIView.LoadDataState> {
        return Binder(self.base) {
            view, state in
            let emptyView = self.base.viewWithTag(UIView.emptyViewTag)
            let failedView = self.base.viewWithTag(UIView.failedViewTag)
            let loadingView = self.base.viewWithTag(UIView.loadingViewTag)
            switch state {
            case .empty:
                if let v = emptyView {
                    self.base.bringSubviewToFront(v)
                }
                emptyView?.fadeIn()
                failedView?.fadeOut()
                loadingView?.fadeOut()
            case .failed:
                failedView?.fadeIn()
                emptyView?.fadeOut()
                loadingView?.fadeOut()
            case .loading:
                loadingView?.fadeIn()
                emptyView?.fadeOut()
                failedView?.fadeOut()
            case .none:
                loadingView?.fadeOut()
                emptyView?.fadeOut()
                failedView?.fadeOut()
            }
        }
    }
    var isEmptyData: Binder<Bool> {
        return Binder(self.base) {
            view, isEmptyData in
            let emptyView = self.base.viewWithTag(UIView.emptyViewTag)
            if isEmptyData {
                emptyView?.fadeIn()
            } else {
                emptyView?.fadeOut()
            }
            
        }
    }
}

extension UIView {
    static let emptyViewTag = 800
    static let loadingViewTag = 801
    static let failedViewTag = 802
    
    enum LoadDataState {
        case none, empty, failed, loading
    }
    
    func configureDataSetView(options: [LoadDataOptions: String], isFullScreen: Bool = true) {
        let keys = options.keys
        if keys.contains(.empty) {
            let emptyViewVc = EmptyViewController.create(title: options[.empty])
            emptyViewVc.view.tag = UIView.emptyViewTag
            emptyViewVc.view.isHidden = true
            self.addSubview(emptyViewVc.view)
            if isFullScreen {
                emptyViewVc.view.frame = bounds
            } else {
                emptyViewVc.view.snp.makeConstraints { maker in
                    maker.center.equalToSuperview()
                }
            }
        }
    }
}

extension UIView {

    struct LoadDataOptions: OptionSet {
        let rawValue: Int
        init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        static let empty = LoadDataOptions(rawValue: 1 << 0)
        static let loading = LoadDataOptions(rawValue: 1 << 1)
        static let failed = LoadDataOptions(rawValue: 1 << 2)

        static let `default`: LoadDataOptions = [.empty]
        static let verbose: LoadDataOptions = [.empty, .loading, failed]
        
    }
}

extension UIView.LoadDataOptions: Hashable {}



extension Reactive where Base: UIView {
    var height: Binder<CGFloat> {
        return Binder<CGFloat>(self.base) {
            view, height in
            view.height = height
        }
    }
}

extension Reactive where Base: UITableView {
    var headerHeight: Binder<CGFloat> {
        return Binder<CGFloat>(self.base) {
            tableView, height in
            tableView.tableHeaderView?.height = height
            tableView.reloadData()
        }
    }
}
