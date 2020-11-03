//
//  UIScrollView+Simultaneously.swift
//  TianXin
//
//  Created by pretty on 10/19/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

extension UIScrollView: UIGestureRecognizerDelegate {
    struct UIScrollViewAssociatedKey {
        static var shouldSimultaneously = "ShouldSimultaneously"
    }
    var shouldSimultaneously: Bool {
        get {
            return objc_getAssociatedObject(self, &UIScrollViewAssociatedKey.shouldSimultaneously) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &UIScrollViewAssociatedKey.shouldSimultaneously, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return shouldSimultaneously
    }
}

//class SimultaneouslyScrollView: UIScrollView, UIGestureRecognizerDelegate {
//    var shouldSimultaneously = true
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return shouldSimultaneously
//    }
//}
