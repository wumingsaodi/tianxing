//
//  RecentSearchCell.swift
//  TianXin
//
//  Created by pretty on 10/10/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxGesture
import RxSwift
import RxCocoa

class RecentSearchCell: RxCollectionViewCell<RecentSearchCellViewModel> {
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
 
    override func bind(_ model: RecentSearchCellViewModel) {
        super.bind(model)
        
        model.deleting.map{ !$0 }.asDriver(onErrorJustReturn: true)
            .drive(deleteButton.rx.isHidden)
            .disposed(by: cellDisposeBag)
        
        model.title.asDriver().drive(titleLabel.rx.text).disposed(by: cellDisposeBag)
        
        self.titleLabel.superview?.rx.longPressGesture()
            .when(.began)
            .subscribe(onNext: { _ in
                model.deleting.toggle()
            }).disposed(by: cellDisposeBag)
        
        deleteButton.rx.tap
            .map { model.item.id }
            .bind(to: model.onDelete)
            .disposed(by: cellDisposeBag)
    }
}
