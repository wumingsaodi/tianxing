//
//  TopicEntity.swift
//  TianXin
//
//  Created by pretty on 10/7/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation

struct Topic: Codable {
    var id: Int
    var cover: String?
    var number: Int = 0
    var title: String?
    var remark: String?
}
