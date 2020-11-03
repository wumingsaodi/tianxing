//
//  CachePolicyGettable.swift
//  TianXin
//
//  Created by pretty on 10/10/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import Moya

protocol NetworkCachable {
    var cachePolicy: URLRequest.CachePolicy { get }
}

final class NetworkCachingPlugin: PluginType {
    
    /// 初始化缓存插件
    /// - Parameters:
    ///   - configuration: URLSessionConfiguration
    ///   - inMemoryCapacity: 内存占用大小 默认为20M
    ///   - diskCapacity: 硬盘占用大小 默认为100M
    ///   - diskPath: 硬盘地址 默认为 NSTemporaryDirectory
    init (configuration: URLSessionConfiguration, inMemoryCapacity: Int = 20^Mb, diskCapacity: Int = 100^Mb, diskPath: String? = Configs.Path.Documents) {
        configuration.urlCache = URLCache(memoryCapacity: inMemoryCapacity, diskCapacity: diskCapacity, diskPath: diskPath)
    }
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        if let cacheableTarget = target as? NetworkCachable {
            var mutableRequest = request
            mutableRequest.cachePolicy = cacheableTarget.cachePolicy
            return mutableRequest
        }
        return request
    }
}
extension MoyaProvider {
    // 清楚缓存
    func clearCache(targets: [Target]) {
        guard let urlCache = self.session.sessionConfiguration.urlCache else { return }
        if targets.isEmpty {
            urlCache.removeAllCachedResponses()
        } else {
            targets.forEach { urlCache.removeCachedResponse(for: URLRequest(url: $0.baseURL.appendingPathComponent($0.path)))}
        }
    }
}

