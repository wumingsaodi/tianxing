//
//  NetWorkingHelper.swift
//  TianXin
//
//  Created by SDS on 2020/9/17.
//  Copyright © 2020 SDS. All rights reserved.
//
/**
 公钥
 */
//private let publicKey = "-----BEGIN PUBLIC KEY----- MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC6amslTkuX0LsXJd8KVkWp1HdppmqrynpS4kykQquQHyEmzunIMJxqdZgul9Fn/VCoj/p9+uesD50QXB4eQCl/sAXM/kFq2fSrVdr7ZgyPIL/pFAhimEmEv0Adg1fasZ7kWbf6OTIitO1BJ0FVDdtJ+3dP4BZMNJ6zDW3EQiLg/QIDAQAB-----END PUBLIC KEY-----"
private let publicKey = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC6amslTkuX0LsXJd8KVkWp1HdppmqrynpS4kykQquQHyEmzunIMJxqdZgul9Fn/VCoj/p9+uesD50QXB4eQCl/sAXM/kFq2fSrVdr7ZgyPIL/pFAhimEmEv0Adg1fasZ7kWbf6OTIitO1BJ0FVDdtJ+3dP4BZMNJ6zDW3EQiLg/QIDAQAB"
let NetWorkingRequistSuccess = "NetWorkingRequistSuccess"
let NetWorkingRequistError   = "NetWorkingRequistError"

let netDefualtFail = { (error:SDSError) ->Void in
    SDSHUD.showError(error.errMsg)
}

//import AFNetworking
import UIKit
import Heimdall
import Alamofire

let isProduce:Bool =  false

enum SDSHTTPMethod:String {
    case get = "GET"
    case post = "POST"
}
let BaseUrl:String =   "http://tianxing.viphk.ngrok.org"  //  "http://runpayorder.viphk.ngrok.org"
//let BaseUrl:String = "http://103.108.142.100:8999"
let HeardSet:[String:String] = [String:String]()
typealias SuccessBlock = ([String:Any])->Void
typealias FailBlock = (_ err:SDSError)->Void
class NetWorkingHelper: NSObject {
    /**
     设置请求超时
     */
    static var AFSession:Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        let reachAbility = NetworkReachabilityManager()
        if (reachAbility!.isReachable){
            configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        }else{
            configuration.requestCachePolicy = .returnCacheDataDontLoad
        }
        let session =    Alamofire.Session(configuration: configuration)
        return session
    }()
    static var VidoSession:Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60*3
        let session =    Alamofire.Session(configuration: configuration)
        return session
    }()

    /**
     请求头，暂时不需要请求头
     */
    static   func getHttpsHead() -> HTTPHeaders {
        let headers =   HTTPHeaders.default
        //        headers.add(name: <#T##String#>, value: <#T##String#>)
        return headers
    }
    static func GetRSADict(params:[String:Any])->[String:Any]{
        let publicData = Data.init(base64Encoded: publicKey)
        let partHeim  =  Heimdall.init(publicTag: "", publicKeyData: publicData)
        let jsonStr =   self.getJsonStrFrom(dict: params)
        let enStr =    partHeim?.encrypt(jsonStr!)
        return ["inputParamJson":enStr! as Any]
    }
    static func normalGetRequest(url:String,params:[String:Any] = [:],success:@escaping SuccessBlock,fail:@escaping FailBlock = netDefualtFail,isBaseUrl:Bool = true,isRestore:Bool = true){
        normalRequest(url: url, params: params, method: .get, success: success, fail: fail,isBaseUrl: isBaseUrl,isRestore: isRestore)
    }
    static func normalPost(url:String,params:[String:Any],success:@escaping SuccessBlock,fail:@escaping FailBlock = netDefualtFail ,isBaseUrl:Bool = true,isRestore:Bool = true){
        normalRequest(url: url, params: params, method: .post, success: success, fail: fail,isBaseUrl: isBaseUrl,isRestore: isRestore)
    }
    
    /**
     一般的 get post 请求
     */
    private  static func normalRequest (url:String,params:[String:Any],method:HTTPMethod,success:@escaping SuccessBlock,fail:@escaping FailBlock,isBaseUrl:Bool = true,isRestore:Bool = true){
        var requestUrl =  url
        if isBaseUrl {
            requestUrl = BaseUrl +  url
            //            requestUrl = BaseUrl + "/gl/square/recommendSquare"
        }
        var afnParams = params
        afnParams.updateValue(LocalUserInfo.share.userId as Any, forKey: "userId")
        if isProduce {
            afnParams = GetRSADict(params: afnParams)
        }else{
            let str =    self.getJsonStrFrom(dict: afnParams)
            afnParams = ["inputParamJson":str!]
        }
        //        AFNHttp(url: requestUrl, params: afnParams, method: method, success: success, fail: fail)
        
        
        NJLog("url:\(url),params:\(afnParams)")
        if sdsKeyWindow != nil {
            SDSHUD.showloading()
        }
//        AFSession.request(requestUrl,method: method, parameters: afnParams,headers: self.getHttpsHead()).responseJSON { (<#AFDataResponse<Any>#>) in
//            <#code#>
//        }
        AFSession.request(requestUrl,method: method, parameters: afnParams,headers: self.getHttpsHead()).responseJSON { (res) in
            switch res.result {
            case .success(let json):
                SDSHUD.hide()

//                if isRestore {
//
//                    let caches = CachedURLResponse(response: res.response!, data: res.data!, userInfo: nil, storagePolicy: .allowed)
//                    URLCache.shared.storeCachedResponse(caches, for: res.request!)
//                    (response: res.response, data: res.result, userInfo: nil, storagePolicy: .allowed)
                    //let cachedURLResponse = NSCachedURLResponse(response: res!, data: (data as NSData), userInfo: nil, storagePolicy: .Allowed)
//                    NSURLCache.sharedURLCache().storeCachedResponse(cachedURLResponse, forRequest: request)
//                }
                NJLog("url:\(url)\n res:\(json )")
                let dict = json as! [String:Any]
                let code = dict["code"] as? String
                let messge =  dict["message"] as? String
                if code == nil || code == "success" {
                    success(json  as! [String : Any])
                    
                }else{
                    NJLog("url:\(url)\n error:\(messge ?? "")")
                    let sdsEor = SDSError()
                    sdsEor.errMsg = messge!
                    fail(sdsEor)
                }
                NotificationCenter.default.post(name: NSNotification.Name.init(NetWorkingRequistSuccess), object: nil)
                break
            case .failure(let error):
                SDSHUD.hide()
//                if isRestore {
//                    if error.errorDescription == "URLSessionTask failed with error: resource unavailable" {
//                        let response =   URLCache.shared.cachedResponse(for: res.request!)
//                        let json = try? JSONSerialization.jsonObject(with: response!.data, options: .allowFragments)
//                        success(json as! [String : Any])
//                    }
//                   
//
//                }
                let sdsError = SDSError.init(error: error)
                fail(sdsError)
                NotificationCenter.default.post(name: NSNotification.Name.init(NetWorkingRequistError), object: nil)
                break
            }
        }
        
    }
    /**
     上传图片文件专用
     */
    static func uploadImage(images:[UIImage],success:@escaping (_ fileName:[String])->Void,fail:@escaping (( _  error:SDSError)->Void) = netDefualtFail){
        var datas:[Data] = [Data]()
        for img in images {
            guard let imgdata =  img.jpegData(compressionQuality: 1) else {
                NJLog("图片系列化成data失败")
                return
            }
            datas.append(imgdata)
        }
        let url = BaseUrl +    api_uploadImgUrl  //"/gl/user/uploadPic"
        upload(url: url, params: [:], datas: datas, name: "pic", mineType: "image/jpeg", headers: dataHeaders,success: { (dict) in
            if  let  files =  dict["fileList"] as? [String]{
                success(files)
            }else{
              let str =  dict["fileList"] as? String ?? ""
                success([str])
            }
    
        },fail: fail)
    }
    /**
     上传视频专用
     */
    static func uploadVideo(videoUrlStr:URL,success:@escaping (_ fileName:String)->Void,fail:@escaping (( _  error:SDSError)->Void) = netDefualtFail){
        AFSession.sessionConfiguration.timeoutIntervalForRequest = 60 * 3
        let url:String = BaseUrl + api_uploadImgUrl
        upload(url: url, params: [:], datas: nil, name: "pic",fileUrl: videoUrlStr, mineType: "", headers: dataHeaders,success: { (dict) in
            if  let  files =  dict["fileList"] as? [String]{
                success(files.first ?? "")
            }else{
              let str =  dict["fileList"] as! String
                success(str)
            }
    
        },fail: fail)
    }
    static var dataHeaders:HTTPHeaders = {
        var headers =  HTTPHeaders.default
        headers.add(name: "Content-type", value: "multipart/form-data")
        headers.add(name: "Content-Disposition", value: "form-data")
        return headers
    }()
    /**
     上传所有的文件的接口
     */
    static func upload(url:String,params:[String:Any],datas:[Data]?,name:String,fileUrl:URL? = nil,mineType:String,headers:HTTPHeaders,success:@escaping(_ dict:[String:Any])->Void,fail:@escaping FailBlock){
        if sdsKeyWindow != nil {
            SDSHUD.showloading()
        }
   
        VidoSession.upload(multipartFormData: { (multiPartData) in
            for (key,value) in params {
                //上传参数拼接
                multiPartData.append((value as AnyObject).data, withName: key)
            }
            if fileUrl != nil {
                multiPartData.append(fileUrl!, withName: name)
                return
            }
            if datas == nil {
                return
            }
            for data in datas! {
                    multiPartData.append(data, withName: name, fileName: nil, mimeType: mineType)
                
            }
        }, to: url,  method: .post, headers: headers).responseJSON { (res) in
            SDSHUD.hide()
            switch res.result {
            case .success(let json):
                guard let dict = json as? [String : Any] else{
                    return
                }
                NJLog("文件路径url:\(url),json:\(dict)")

                if dict["code"] == nil || dict["code"] as! String == "success"{
                    success(dict)
                }else{
                    let error = SDSError()
                    error.errMsg = (dict["message"] as? String) ?? ""
                    fail(error)
                }
               
                break
            case .failure(let error):
                NJLog("文件路径url:\(url),error:\(error)")
                fail(SDSError.init(error: error))
                break
            }
        }
    }
    
    
    static func getJsonStrFrom(dict:[String:Any])->String?{
        let data:Data! = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed)
        let str = String.init(data: data, encoding: .utf8)
        return str
    }
    //    static func AFNHttp(url:String,params:[String:Any],method:SDSHTTPMethod,success:@escaping  SuccessBlock,fail:@escaping FailBlock){
    //        NJLog("url:\(url),params:\(params)")
    //        if sdsKeyWindow != nil {
    //            SDSHUD.showloading()
    //        }
    //        if method == .get {
    //            manager.get(url, parameters: params, headers: nil, progress: nil, success: { (task, response) in
    //                SDSHUD.hide()
    //                success(response as Any as! [String : Any])
    //            }) { (task, error) in
    //                SDSHUD.hide()
    //                let sdsEor =  SDSError.init(error: error as NSError)
    //                fail(sdsEor)
    //            }
    //        }else{
    //            manager.post(url, parameters: params, headers: nil, progress: nil, success: { (task, res) in
    //                SDSHUD.hide()
    //                NJLog("url:\(url)\n res:\(res ?? "")")
    //                let dict = res as! [String:Any]
    //                let code = dict["code"] as? String
    //                let messge =  dict["message"] as? String
    //                if code == nil || code == "success" {
    //                    success(res as Any as! [String : Any])
    //
    //                }else{
    //                    NJLog("url:\(url)\n error:\(messge ?? "")")
    //                    let sdsEor = SDSError()
    //                    sdsEor.errMsg = messge!
    //                    fail(sdsEor)
    //                }
    //
    //            }) { (task, error) in
    //                SDSHUD.hide()
    //                NJLog("url:\(url)\n error:\(error)")
    //                let sdsEor =  SDSError.init(error: error as NSError)
    //                fail(sdsEor)
    //            }
    //        }
    //    }
    //    static  var manager:AFHTTPSessionManager = {
    //        var manger:AFHTTPSessionManager!
    //        DispatchQueue.once(token: "afnAreset") {
    //            manger = AFHTTPSessionManager.init()
    //            manger.requestSerializer.timeoutInterval = 10
    //        }
    //        return manger
    //    }()
    //
    
}






class SDSError: NSObject {
    var code:Int = -100;
    var errMsg:String = "" {
        didSet{
            if errMsg.contains("登录失效") {
                LocalUserInfo.share.userId = nil
               _ = kAppdelegate.islogin(isNeedLogin: true, isRootVC: true)
            }
        }
    }
    
    convenience  init(error:AFError) {
        self.init()
        if error.responseCode == -100 {
            code = error.responseCode ?? 0
            errMsg  = error.errorDescription ?? ""
        }else{
            code = error.responseCode ?? 0
            errMsg  = error.errorDescription ?? ""
        }
        if errMsg.contains("登录失效") {
            LocalUserInfo.share.userId = nil
           _ = kAppdelegate.islogin(isNeedLogin: true, isRootVC: true)
        }
        
    }
    
    //    required init?(coder: NSCoder) {
    //        fatalError("init(coder:) has not been implemented")
    //    }
}
extension SDSError: Error {}
