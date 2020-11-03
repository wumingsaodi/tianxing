//
//  AvatarSelectionCellViewModel.swift
//  TianXin
//
//  Created by pretty on 10/17/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct AvatarSelectionCellViewModel {
    let avatarUrl = BehaviorRelay<String?>(value: nil)
    let name = BehaviorRelay<String?>(value: nil)
    
    let isSelected = BehaviorRelay<Bool>(value: false)
    let item: CircleItem
    init(_ item: CircleItem) {
        self.item = item
        avatarUrl.accept(item.recommendPic)
        name.accept(item.recommendName)
    }
}
