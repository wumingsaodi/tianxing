//
//  PayTypeModel.swift
//  TianXin
//
//  Created by SDS on 2020/10/13.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
/**
 <#pramas#>
 */
class PayTypeModel :  BaseModel {
       // paycode =  wechat
     //     create_time =  2020-10-02 14 = 06 = 22
    /**
     isinput 0可以输入 9不能输入
     */
     var isinput =  0
    var   moneyList:[String] =  [String]()
        var  tpaysetid =  1
    var  paytype =  ""
    var  maxamt =  0
    var  minamt =  0
    var  tpayname =  ""
//        var  stopamt =  1000000000
//        var  present_rate =  200
//        var  payvalue =  HF
//        var  easyrecharge =  50001000020000
//        var  update_time =  2020-10-02 15 = 23 = 03
//        var  providerid =  1
       
   
        var  status =  0
}
