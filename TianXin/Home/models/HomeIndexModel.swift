//
//  HomeIndexModel.swift
//  TianXin
//
//  Created by SDS on 2020/10/1.
//  Copyright © 2020 SDS. All rights reserved.
//

class typeItmeModel: BaseModel {
  var  id = 0
  var  orders = 0
  var  picUrl = ""
 var   resourceType = ""
    var type = ""
    
}
import UIKit
class HomeIndexModel: BaseModel {
var chineseList = [HomeItemModel]()
var hotList = [HomeItemModel]()
var touList = [HomeItemModel]()
var hotListType = -1
var chineseListType = -1
var touListType = -1
    
//    var bannerList:BannerListModel = BannerListModel()
    var type:[typeItmeModel] = [typeItmeModel]()
}
