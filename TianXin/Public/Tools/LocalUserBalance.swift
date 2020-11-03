//
//  LocalUserBalance.swift
//  TianXin
//
//  Created by SDS on 2020/10/28.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class UserBalance: BaseModel {
    var totalAssets:Float = 3//KOK钱包
    var balance:Float = 0.0//甜杏钱包
    var coin:Int =  8//K币
}

class LocalUserBalance: NSObject {
    lazy var vm:RechangeViewModel = {
        return  RechangeViewModel()
    }()
 static  let share = LocalUserBalance()
    ///获取用户钱包消息
    func getUserBalance(success:@escaping(_ model: UserBalance)->Void){
        if let  balan = balance {
            success(balan)
        }
        balanceSuccessBlocks.append(success)
    }
    //
    func setUserBalance(model:UserBalance){
        self.balance = model
    }
    //
   func freshUserBalace(type:balanceType){
        vm.requestUserBalance(requestType: type)
    }
    private var balanceSuccessBlocks:[(UserBalance)->Void] = [(UserBalance)->Void]()
    private var balance:UserBalance? = nil  {
        didSet{
            if let ban = balance {
                for blok in balanceSuccessBlocks {
                    blok(ban)
                }
            }
           
        }
    }
    
    override init() {
        super.init()
        freshUserBalace(type: .reload)
    }
}
