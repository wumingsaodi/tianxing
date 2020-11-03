//
//  BaseModel.swift
//  TianXin
//
//  Created by SDS on 2020/10/5.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import HandyJSON
class BaseModel: NSObject,HandyJSON,Codable {
   override required init() {
    }
    override  func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
}
