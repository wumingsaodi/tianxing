//
//  TopicViewCellViewModel.swift
//  TianXin
//
//  Created by pretty on 10/7/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct TopicViewCellViewModel {
    let title = BehaviorRelay<String?>(value: nil)
    let cover = BehaviorRelay<String?>(value: nil)
    let remark = BehaviorRelay<String?>(value: nil)
    let number = BehaviorRelay<String?>(value: nil)
    
    let topic: Topic
    init(with topic: Topic) {
        self.topic = topic
        title.accept(topic.title?.replacingOccurrences(of: "\r\n", with: ""))
        cover.accept(topic.cover)
        remark.accept(topic.remark)
        number.accept("\(topic.number)部")
    }
}
