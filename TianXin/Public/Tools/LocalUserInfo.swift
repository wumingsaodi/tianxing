//
//  LocalUserInfo.swift
//  TianXin
//
//  Created by SDS on 2020/10/7.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import HandyJSON
let UserInfoSavePath = "userInfo.data"
let banarListPath = "BanarList.data"

typealias VoidBlock = ()->Void

typealias LoginBlock = (Bool)->Void
let LoginIdKey = "LoginIdKey"
let sdsSessionId = "sdsSessionId"
let sdsUserNameKey = "sdsUserNameKey"
let sdsPassWordKey = "sdsPassWordKey"
 
let document = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
func saveObjctToFile<T:HandyJSON>(obj:T,filePath:String){
       let dict =  obj.toJSON()
    let savePath  =   document.appendingPathComponent(filePath)
    NSKeyedArchiver.archiveRootObject(dict as Any, toFile: savePath)
}
func getObjectFrom<T:HandyJSON>(path:String,ModelType:T.Type)->T?{
    let path = document.appendingPathComponent(path)
    let  dict =  NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [String:Any]
    return T.deserialize(from: dict)
}
func deleteFile(path:String){
    let path = document.appendingPathComponent(path)
   try? FileManager.default.removeItem(atPath: path)
}
enum BanarType:String {
    case homeIndex = "index_banner"
    case  video_play = "video_play"
    case video_detai = "video_detai"
   case my_account = "my_account"
    case 测试广告位不要删 = "测试广告位不要删"
}

class LocalUserInfo: NSObject {
    static var share = LocalUserInfo()
   private   var banarList: BannerListModel?{
        didSet{
//          NJLog("banarList didSet")
            saveObjctToFile(obj: banarList!, filePath: banarListPath)
            for block in barnarBlocks {
                block(self.banarList!)
            }
        }
    }
    func setBanarList(model:BannerListModel){
        self.banarList = model
    }
   var showPhoto:String{
    var phone = self.userInfo?.phone ?? ""
    //102****5612
    if phone.count > 7 {
        phone = phone[0,3] + "****" + phone[phone.count - 4,4]
    }
    
    return phone
    }
 var showEmail:String {
    var email = self.userInfo?.email ?? ""
    //"sao*********@gmail.com"
    if email.count > 0 {
       let arr  = email.components(separatedBy: "@")
        if arr.count == 2 {
            email = arr[0][0,3] + "****" + "@" + arr[1]
        }
    }
    return email
    }
    
    var sdsUserName:String {
        set{
            UserDefaults.standard.setValue(newValue, forKey: sdsUserNameKey)
        }
        get{
          return  UserDefaults.standard.string(forKey: sdsUserNameKey) ?? ""
        }
    }
    var sdsPassword:String{
        set{
            UserDefaults.standard.setValue(newValue, forKey: sdsPassWordKey)
        }
        get{
            return UserDefaults.standard.string(forKey: sdsPassWordKey) ?? ""
        }
    }
    override init() {
        super.init()
        self.userInfo = getObjectFrom(path: UserInfoSavePath, ModelType: UserInfoModel.self)
        if userInfo != nil, userInfo?.nickName.count ?? 0 == 0 {
            
                userInfo?.nickName = userInfo!.userName
        }
        banarList = getObjectFrom(path: banarListPath, ModelType: BannerListModel.self)

    }
    
    var userInfo:UserInfoModel?{
        didSet{
            for block in UserInfoBlocks {
                block(self.userInfo)
            }
            if userInfo != nil {
                saveObjctToFile(obj: self.userInfo!, filePath: UserInfoSavePath)
            }else{
                //删除
                deleteFile(path: UserInfoSavePath)
            }
           
        }
    }
    
    
    private var UserInfoBlocks:[(_ model:UserInfoModel?)->Void] = [(UserInfoModel?)->Void]()
    private var isLoginBlocks:[LoginBlock] = [LoginBlock]()
    var islogin:Bool {
        if self.userId == nil || self.userId == 0{
            return false
        }
        return true
//        return self.userId == nil ? false : true
    }
    private var _userid:Int = 0
    var userId:Int? {
        set{
            if userId ?? 0 == 0 {//账号删除了
                //充值弹框限制消失
                UserDefaults.standard.removeObject(forKey: NoHomeMoenyPopShow)
            }
            
                for block in isLoginBlocks {
                    if newValue == nil {
                    block(false)
                    }else{
                        block(true)
                    }
                }
            
            _userid = newValue ?? 0
            UserDefaults.standard.set(newValue, forKey: LoginIdKey)
        }
        get{
            if _userid > 0 {
                return _userid
            }
            let useid = UserDefaults.standard.integer(forKey: LoginIdKey)
            return useid
        }
    }

    var sessionId:String? {
        set{
            UserDefaults.standard.set(newValue, forKey: sdsSessionId)
        }
        get{
            return UserDefaults.standard.string(forKey: sdsSessionId)
        }
    }
    private var barnarBlocks:[(BannerListModel)->Void] = [(BannerListModel)->Void]()
    func getBanar(success: @escaping(_ banarList: BannerListModel)->Void){
        if let banarList = self.banarList {
            success(banarList)
        }
        barnarBlocks.append(success)
    }
    func updateLoginSate(_ block:@escaping (_ isLogin:Bool)->Void){
        if self.islogin {
            block(true)
        }else{
            block(false)
        }
       self.isLoginBlocks.append(block)
    }
    func setLoginInfo(model:UserInfoModel?){
        self.userInfo = model
//        saveObjctToFile(obj: model, filePath: UserInfoSavePath)
    }
    func getLoginInfo(success: @escaping (_ model:UserInfoModel?)->Void){
        UserInfoBlocks.append(success)
        if (self.userInfo != nil) {
            success(self.userInfo!)
        }

      
    }
    func  refreshUserInfo(){
            let vm = LoginViewModel()
            vm.requestGetUserInfo()
        }

}
