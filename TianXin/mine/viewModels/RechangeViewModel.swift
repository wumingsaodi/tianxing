//
//  RechangeViewModel.swift
//  TianXin
//
//  Created by SDS on 2020/10/13.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class RechangeViewModel: NSObject {
    func requistGetPlayTypeList(success:@escaping(_ models:[PayTypeModel?])->Void){
        NetWorkingHelper.normalPost(url: api_getPayTypes, params: [:]) { (dict) in
            guard let dataDict = dict["data"] as? Array<Any> ,let models = [PayTypeModel].deserialize(from: dataDict) else{
                return
            }
            success(models)
        }
    }
    func requistPayDownOrder(tpaysetid:String,money:String,success:@escaping()->Void) {
        NetWorkingHelper.normalPost(url: api_payDwonOrder, params: ["tpaysetid":tpaysetid ,"money":money]) { (dict) in
            guard let  dataDict = dict["data"] as? [String:Any], let urlStr = dataDict["url"] as? String,let  url = URL(string: urlStr) else{
                return
            }
            if UIApplication.shared.canOpenURL(url){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
//            success()
//            LocalUserBalance.share.freshUserBalace(type: .manual)
        }
    }
    /**
     
     包网查询账户总资产
     */
    
    func requestUserBalance(requestType:balanceType  = .reload) {
        NetWorkingHelper.normalPost(url: "/gl/user/getActualTotalAssets", params: ["requestType":requestType.rawValue]) { (dict) in
            guard let dataDict = dict["data"] as? [String:Any], let model = UserBalance.deserialize(from: dataDict)else{
                return
            }
            LocalUserBalance.share.setUserBalance(model: model)
        }
    }

}
