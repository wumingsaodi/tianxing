//
//  LoginViewModel.swift
//  TianXin
//
//  Created by SDS on 2020/10/6.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class LoginViewModel: NSObject {
//    static var share:LoginViewModel = LoginViewModel()
//
    static var share:LoginViewModel = LoginViewModel()

    var Registkey:String = ""
//    var registcode:String = ""
    /**
     登陆
     */
    func requistLogin(userName:String,password:String,longitude:String = "",latitude:String = "",success:@escaping ()->Void,fail:(()->Void)? = nil){
        let params = ["userName":userName,
                      "password":password,
                      "longitude":longitude,
                      "latitude":latitude,
                      "uuid":getUUID()
                        ]
        NetWorkingHelper.normalPost(url: api_login, params: params, success: {[weak self] (dict) in
            success()
            guard  let dataDict = dict["data"] as? [String:Any] else{
                return
            }
            LocalUserInfo.share.userId = dataDict["userId"] as? Int
            LocalUserInfo.share.sessionId  = dataDict ["sessionId"] as? String
            self?.requestGetUserInfo()
            //刷新余额
            LocalUserBalance.share.freshUserBalace(type: .reload)
        }) { (error) in
            SDSHUD.showError(error.errMsg)
        }
    }
    /**
     退出登录
     */
    func requestLogout(success:@escaping()->Void){
        NetWorkingHelper.normalPost(url: api_loginout, params: [:]) { (dict) in
            LocalUserInfo.share.setLoginInfo(model:nil)
            LocalUserInfo.share.userId = nil
            SDSHUD.showSuccess("成功退出登录")
            success()
//            kAppdelegate.islogin(isNeedLogin: true, isRootVC:true)
//            success()
        }
    }
    /**
     注册用户
     */
    func requistRegisterUse(userNameuser:String,password:String,inviteCode:String,code:String,success:@escaping ()->Void,fail:@escaping (String)->Void){
        let params = ["userName":userNameuser,
                      "password":password,
                      "inviteCode":inviteCode,
                      "key":Registkey,
                      "code": code]
        NetWorkingHelper.normalPost(url: api_registerUser, params: params, success: { [weak self] (dict) in
         success()
            LocalUserInfo.share.userId = dict["userId"] as? Int
            LocalUserInfo.share.sessionId  = dict ["sessionId"] as? String
//            self?.requestGetUserInfo()
            
        }) { (eror) in
            SDSHUD.showError(eror.errMsg)
            fail(eror.errMsg)
          }
    }
    func checkRandomCode(code:String,success:@escaping ()->Void,fail:@escaping()->Void){
        NetWorkingHelper.normalPost(url: api_checkRndomCode, params: ["code":code,"key":self.Registkey],success: { (dict) in
            success()
        }){ (error) in
            fail()
        }
    }
    /**
     获取随机验证码
     */
    func requistRandomCodes(success:@escaping (_ key:String,_ img:UIImage)->Void) {
        NetWorkingHelper.normalPost(url: api_getRandomCode, params: [:], success: { (dict) in
//                        let imgw = UIImage.init(named: "icon_Avatar")
//            let data2 = imgw?.pngData()
////            let dataq = Data()
//            let str = data2!.base64EncodedString(options: .lineLength64Characters)
            
            let imgdatastr = dict["photo"] as! String
            let newimgStr =  imgdatastr.components(separatedBy: ",")[1]
            let imgdata = NSData.init(base64Encoded: newimgStr, options: .ignoreUnknownCharacters)
            let img = UIImage(data: imgdata! as Data)
            self.Registkey = dict["key"] as! String
//            self.registcode = imgdatastr
            success(dict["key"] as! String,img!)
        }) { (error) in
            SDSHUD.showError(error.errMsg)
        }
    }
    /**
     获取用户消息
     */
    func requestGetUserInfo(){
        
        NetWorkingHelper.normalPost(url: api_getUserInfo, params: [:]) { (dict) in
            guard let userInfoDict = dict["userInfo"] as? [String:Any], let model =   UserInfoModel.deserialize(from: userInfoDict)else {
        NJLog("解析错误")
        SDSHUD.showError("解析错误")
        return
       }
            LocalUserInfo.share.setLoginInfo(model: model)
//            success(model)
        } fail: { (error) in
            SDSHUD.showError(error.errMsg)
        }

    }

}

