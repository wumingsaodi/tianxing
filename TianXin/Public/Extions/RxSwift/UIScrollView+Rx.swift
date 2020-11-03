//
//  UIScrollView+Rx.swift
//  TianXin
//
//  Created by pretty on 10/17/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension Reactive where Base: UIScrollView {
    var selectedIndex: Binder<Int> {
        return  Binder<Int>(self.base) {
            scrollView, index in
            // 超出scroll view
            let contentWidth = scrollView.contentSize.width
            if Int(contentWidth / scrollView.width) < index {
                scrollView.scrollRectToVisible(.init(x: contentWidth - scrollView.width, y: scrollView.contentOffset.y, width: scrollView.width, height: scrollView.contentSize.height), animated: true)
            } else if index < 0 {
                scrollView.scrollRectToVisible(.init(x: 0, y: scrollView.contentOffset.y, width: scrollView.width, height: scrollView.contentSize.height), animated: true)
            } else {
                scrollView.scrollRectToVisible(.init(x: CGFloat(index) * scrollView.width, y: scrollView.contentOffset.y, width: scrollView.width, height: scrollView.contentSize.height), animated: true)
            }
            
        }
    }
}
