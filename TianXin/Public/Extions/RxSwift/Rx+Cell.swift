//
//  Rx+Cell.swift
//  TianXin
//
//  Created by pretty on 10/31/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension UITableViewCell {
    struct UITableViewCellAssociatedKey {
        static var disposeBag = "disposeBag"
    }
    var disposeBag: DisposeBag? {
        get {
            return objc_getAssociatedObject(self, &UITableViewCellAssociatedKey.disposeBag) as? DisposeBag
        }
        set {
            objc_setAssociatedObject(self, &UITableViewCellAssociatedKey.disposeBag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UICollectionViewCell {
    struct UICollectionViewCellAssociatedKey {
        static var disposeBag = "disposeBag"
    }
    var disposeBag: DisposeBag? {
        get {
            return objc_getAssociatedObject(self, &UICollectionViewCellAssociatedKey.disposeBag) as? DisposeBag
        }
        set {
            objc_setAssociatedObject(self, &UICollectionViewCellAssociatedKey.disposeBag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

