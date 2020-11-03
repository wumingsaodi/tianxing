//
//  MoneyRecordViewModel.swift
//  TianXin
//
//  Created by SDS on 2020/10/28.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import HandyJSON
struct OrderModel:HandyJSON  {
    var orderno = ""
    var  realamt = 0
    var orderstatus = ""
    var   ordernote = ""
    var  user_id = 0
    var sumamt = 0
    var orderdate = ""
    var type = ""
    var ordertype =  1
}


class MoneyRecordViewModel: NSObject {
    
    /**
     获取订单
     ordertype
     1 充值记录 2 转账记录
     */
    func requiestOrderList(ordertype:Int,pageNumber:Int,pageSize:Int = 10,keywords:String = "", orderstatus:String = "",success:@escaping(_ models: [OrderModel], _ isNoMore:Bool)->Void)  {
        NetWorkingHelper.normalPost(url: "/gl/payment/getOrderList", params: ["ordertype":ordertype,"pageNumber":pageNumber,"pageSize":pageSize,"keywords":keywords,"orderstatus":orderstatus]) { (dict) in
            guard let datadict = dict["data"] as? [String:Any],let orderdict = datadict["orderList"] as? [String:Any],let listDict = orderdict["list"] as? [Any], let models = [OrderModel].deserialize(from: listDict) else{
                SDSHUD.showError("解析错误")
                return
            }
            if models.count == 0 {
                success ([OrderModel](),true)
                return
            }
            let newModels = models.map({$0!})
            let isNomore = newModels.count < pageSize ? true : false
            success(newModels,isNomore)
        }
    }
}
