//
//   OViewModel.swift
//  TianXin
//
//  Created by pretty on 10/10/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class RecentSearchCellViewModel {
    let deleting = BehaviorRelay<Bool>(value: false)
    let title = BehaviorRelay<String?>(value: nil)
    
    let onDelete = PublishSubject<Int>()
    
    let item: SearchItem
    init(_ model: SearchItem) {
        self.item = model
        title.accept(model.content)
    }
}
