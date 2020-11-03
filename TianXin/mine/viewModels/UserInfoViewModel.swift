//
//  UserInfoViewModel.swift
//  TianXin
//
//  Created by SDS on 2020/10/8.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
enum balanceType:String {
    case reload = "reload"
    case  manual = "manual"
}
class UserInfoViewModel: NSObject {
    var usermodel:UserInfoModel = UserInfoModel()
    /**
     更新用户信息
     */
    func uploadUserInfo(img:UIImage? = nil,age:String = "",gender:String = "",userSign:String = "",nickName:String = "",success:((_ model:UserInfoModel)->Void)? = nil){
        if img != nil {
            NetWorkingHelper.uploadImage(images: [img!]) {[weak self] (fileName) in
                let avaver = fileName.first
                self?.priveUploadUserInfo(userLogo:avaver!,age: age, gender: gender, userSign: userSign, success: success)
            }
        }else{
            priveUploadUserInfo(age: age, gender: gender, userSign: userSign,nickName: nickName, success: success)
        }
    
    }
 private   func  priveUploadUserInfo(userLogo:String = "",age:String = "",gender:String = "",userSign:String = "",nickName:String = "",success:((_ model:UserInfoModel)->Void)? = nil) {
        let params = ["userLogo":userLogo,
                      "age":age,
                      "gender":gender,
                      "userSign":userSign,
                      "nickName":nickName
        ]
        NetWorkingHelper.normalPost(url: api_updateUserInfo, params: params) { [weak self](dict) in
           guard let model = UserInfoModel.deserialize(from: dict)
           else{
            return
           }
            self?.usermodel = model
            LocalUserInfo.share.refreshUserInfo()
            if let success = success {
                success(model)
            }
            
        }
    }
    /**
     检查是不是绑定的手机号或邮箱
     */
    func requistCheckIsBingPhoneOrEmail(phone:String,isEmail:Bool,success:@escaping()->Void){
        let userName = LocalUserInfo.share.sdsUserName
        var params = ["userName": userName,"phone":phone]
        if isEmail {
            params = ["userName": userName,"email":phone]
        }
        NetWorkingHelper.normalPost(url: api_isbindingPhoneOrEmail,params: params) { (dict) in
            success()
        } fail: { (eror) in
            SDSHUD.showError(eror.errMsg)
        }

    }
    /**
     手机验证码
     */
    func requistSendPhoneCode(phone:String,reg:String = "0",success:@escaping()->Void) {
        requistCheckIsBingPhoneOrEmail(phone: phone, isEmail: false) {
            NetWorkingHelper.normalPost(url: api_iphoneSendCode, params: ["phone":phone,"reg":reg]) { (dict) in
                success()
            }
        }
      
    }
    /**
     邮箱验证码
     */
    func requistSendEmailCode(email:String,success:@escaping()->Void) {
        requistCheckIsBingPhoneOrEmail(phone: email, isEmail: true) {
            NetWorkingHelper.normalPost(url: api_emailSendCode, params: ["email":email]) { (dict) in
              success()
            }
        }
      
    }
    /**
    绑定or 更换手机
     */
    func requistUploadIphone(phone:String,code:String,success:@escaping()->Void) {
        NetWorkingHelper.normalPost(url: api_updateUerPhone, params: ["phone":phone,"code":code]) { (dict) in
            LocalUserInfo.share.refreshUserInfo()
            success()
        }
    }
    /**
    绑定or 更换邮箱
     */

    func requistUploadEmail(email:String,code:String,success:@escaping()->Void){
        NetWorkingHelper.normalPost(url: api_updateUerEmail, params: ["email":email,"code":code]) { (dict) in
            LocalUserInfo.share.refreshUserInfo()
            success()
        }
    }
    /**
     重置密码或忘记密码接口
     */
    func resetPassword(code:String,password:String,aginPassword:String,phoneOrEmail:String,success:(()->Void)? = nil,fail:@escaping (SDSError)->Void) {
        NetWorkingHelper.normalPost(url: api_resetPassword, params: ["code":code,"password":password,"secondPassword":aginPassword,"phone":phoneOrEmail],success: { (dict) in
         
           _ = kAppdelegate.islogin(isNeedLogin: true, isRootVC: true)
            if let blcok = success{
               blcok()
            }
        
          
        }){(error) in
            fail(error)
        }
    }
}
