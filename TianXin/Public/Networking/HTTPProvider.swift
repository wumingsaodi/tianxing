//
//  HTTPProvider.swift
//  TianXin
//
//  Created by pretty on 10/7/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import Moya
import RxSwift

class HttpProvider<Target> where Target: Moya.TargetType {
    private let online: Observable<Bool>
    fileprivate let provider: MoyaProvider<Target>
    
    static var `default`: MoyaProvider<Target> {
        let cachePlugin = NetworkCachingPlugin(configuration: MoyaProvider<Target>.defaultAlamofireSession().sessionConfiguration)
        return MoyaProvider<Target>(plugins: [NetworkLoggerPlugin(), cachePlugin])
    }
    
    init(endpointClosure: @escaping MoyaProvider<Target>.EndpointClosure = MoyaProvider<Target>.defaultEndpointMapping,
         requestClosure: @escaping MoyaProvider<Target>.RequestClosure = MoyaProvider<Target>.defaultRequestMapping,
         stubClosure: @escaping MoyaProvider<Target>.StubClosure = MoyaProvider<Target>.immediatelyStub,
         session: Session = MoyaProvider<Target>.defaultAlamofireSession(),
         plugins: [PluginType] = [NetworkLoggerPlugin()],
         trackInflights: Bool = false,
         online: Observable<Bool> = connectedToInternet()) {
        self.online = online
        self.provider = MoyaProvider(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, session: session, plugins: plugins, trackInflights: trackInflights)
    }
    
    func request(_ token: Target) -> Observable<Moya.Response> {
        let actualRequest = provider.rx.request(token)
        return online
            .ignore(value: false)
            .take(1)
            .flatMap { _ in
                return actualRequest.filterSuccessfulStatusCodes()
                    .do(onSuccess: { (response) in
                        print("response ===> \(response)")
                    }, onError: { error in
                        if let error = error as? MoyaError {
                            switch error {
                            case .statusCode(let response):
                                // 处理code
                                switch response.statusCode {
                                case 400:
                                    break
                                case 500:
                                    break
                                default:
                                    break
                                }
                            default: break
                            }
                        }
                    })
            }
    }
}

extension TargetType {
    static var plugins: [PluginType] {
        var plugins: [PluginType] = []
        if Configs.Network.loggingEnabled == true {
            plugins.append(NetworkLoggerPlugin())
        }
        return plugins
    }
    static func defaultNetworking() -> MoyaProvider<Self> {
        return MoyaProvider<Self>()
//        return .init(plugins: plugins, online: .just(true))
        
    }
}

extension TargetType {
    
    /// 发起请求
    /// - Parameters:
    ///   - keyPath: 解析json model对应的keypath
    func request<T: Codable>(keyPath: String, failsOnEmptyData: Bool = false, type: T.Type, provider: MoyaProvider<Self>) -> Observable<T> {
        return provider.rx.request(self)
            .map(T.self, atKeyPath: keyPath, using: JSONDecoder(), failsOnEmptyData: false)
            .observeOn(MainScheduler.instance)
            .asObservable()
    }
    func request(provider: MoyaProvider<Self>) -> Observable<JSON> {
        return provider.rx.request(self)
            .map{JSON($0.data)}
            .observeOn(MainScheduler.instance)
            .asObservable()
    }
}

