//
//  HomeItemModel.swift
//  TianXin
//
//  Created by SDS on 2020/10/1.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import HandyJSON
class HomeItemModel: NSObject,HandyJSON {
    required override init(){}
    var  category = ""
    var  id = ""
    var  name = "";
    var   pic = "";
    var loveNums:Int = 0
    var historyNum:Int = 0
    var isLike:Bool = false
}
