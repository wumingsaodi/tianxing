//
//  RxTableViewCell.swift
//  TianXin
//
//  Created by pretty on 10/31/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift

class RxTableViewCell<T>: UITableViewCell {
    var cellDisposeBag: DisposeBag!
    var model: T?
    func bind(_ model: T) {
        self.model = model
        cellDisposeBag = DisposeBag()
    }
}

class RxCollectionViewCell<T>: UICollectionViewCell {
    var cellDisposeBag: DisposeBag!
    var model: T?
    func bind(_ model: T) {
        self.model = model
        cellDisposeBag = DisposeBag()
    }
}
