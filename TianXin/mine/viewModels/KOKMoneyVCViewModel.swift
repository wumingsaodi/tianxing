//
//  KOKMoneyVCViewModel.swift
//  TianXin
//
//  Created by SDS on 2020/10/28.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class KOKMoneyVCViewModel: NSObject {
    func changeMoneyToKok(amount:String,success:(()->Void)? =  nil){
        NetWorkingHelper.normalPost(url: "/gl/user/payment", params: ["amount":amount]) { (_) in
            SDSHUD.showSuccess("转出成功")
            self.perform(block: {
                LocalUserBalance.share.freshUserBalace(type: .manual)
            }, timel: 1)
            
        }
        
    }
}
