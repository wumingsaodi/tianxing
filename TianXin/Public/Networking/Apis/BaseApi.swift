//
//  BaseApi.swift
//  TianXin
//
//  Created by pretty on 10/7/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import Moya
import Heimdall

extension TargetType {
    var baseURL: URL {
        return try! Configs.Network.baseUrl.asURL()
    }
    var method: Moya.Method {
        return .post
    }
    var headers: [String: String]?  {
        return nil
    }
}

extension NetworkCachable {
    var cachePolicy: URLRequest.CachePolicy {
        return .useProtocolCachePolicy
    }
}

extension TargetType {
    typealias ParamsGenerator = ([String: Any]) -> [String: Any]
    
    var customGenerate: ParamsGenerator {
        switch Configs.App.env {
        case .dev: return normalParamsGenerator
        default: return encryptParamsGenerate
        }
    }
    var encryptParamsGenerate: ParamsGenerator {
        return { params in
            let publicData = Data(base64Encoded: Configs.publicKey)
            if let jsonStr =  try? params.jsonStr(),
               let partHeim  =  Heimdall(publicTag: "", publicKeyData: publicData),
               let enStr = partHeim.encrypt(jsonStr) {
                return ["inputParamJson": enStr]
            }
            return params
        }
    }
    
    var normalParamsGenerator: ParamsGenerator {
        return { params in
            if let json = try? params.jsonStr() {
                return ["inputParamJson": json]
            }
            return params
        }
    }
}

extension Dictionary where Key == String, Value == Any {
    func jsonStr() throws -> String {
        let data = try JSONSerialization.data(withJSONObject: self, options: .fragmentsAllowed)
        let jsonStr = String(data: data, encoding: .utf8)
        return jsonStr ?? ""
    }
}
