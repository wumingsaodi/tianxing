//
//  NetworkingHelper+Rx.swift
//  TianXin
//
//  Created by pretty on 10/17/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: NetWorkingHelper {
    static func upload(images: [UIImage]) -> Single<[String]> {
        return Single<[String]>.create { single in
            NetWorkingHelper.uploadImage(images: images) { urlstrings in
                single(.success(urlstrings))
            } fail: { error in
                single(.error(error))
            }
            return Disposables.create {
                
            }
        }
    }
    static func upload(videoAssetURL: URL) -> Single<String> {
        return Single<String>.create { single in
            NetWorkingHelper.uploadVideo(videoUrlStr: videoAssetURL) { videoUrl in
                single(.success(videoUrl))
            } fail: { error in
                single(.error(error))
            }
            return Disposables.create {
            }
        }
        
    }
    static func normalPost(url:String,pramas:[String:Any],isBaseUrl:Bool = true,isRestore:Bool = false) ->Single <[String:Any]>{
        return Single<[String:Any]>.create { (sigle) -> Disposable in
            NetWorkingHelper.normalPost(url: url, params: pramas, success: { (dict) in
                sigle(.success(dict))
            }, fail: { (eror) in
                sigle(.error(eror))
            }, isBaseUrl: isBaseUrl, isRestore: isRestore)
            return Disposables.create {
            }
        }
        
    }
    
}
