//
//  Kingfisher+Rx.swift
//  TianXin
//
//  Created by pretty on 10/8/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Kingfisher

extension Reactive where Base: UIImageView {

    public var imageURL: Binder<URL?> {
        return self.imageURL(withPlaceholder: nil)
    }
    public var imageURL100X100: Binder<URL?> {
        return self.imageURL(withPlaceholder: nil, options: [
            KingfisherOptionsInfoItem.processor(DownsamplingImageProcessor(size: .init(width: 100, height: 100)))
        ])
    }
    public var imageURLAndSize: Binder<(URL?, CGSize)> {
        return Binder(self.base) {
            imageView, option in
            imageView.kf.setImage(with: option.0,
                                  placeholder: nil,
                                  options: [
                                    KingfisherOptionsInfoItem.processor(DownsamplingImageProcessor(size: option.1))
                                ],
                                  progressBlock: nil,
                                  completionHandler: { (result) in })
        }
    }

    public func imageURL(withPlaceholder placeholderImage: UIImage?, options: KingfisherOptionsInfo? = nil) -> Binder<URL?> {
        return Binder(self.base, binding: { (imageView, url) in
            imageView.kf.setImage(with: url,
                                  placeholder: placeholderImage,
                                  options: options,
                                  progressBlock: nil,
                                  completionHandler: { (result) in })
        })
    }
}

extension ImageCache: ReactiveCompatible {}

extension Reactive where Base: ImageCache {

    func retrieveCacheSize() -> Observable<Int> {
        return Single.create { single in
            self.base.calculateDiskStorageSize { (result) in
                do {
                    single(.success(Int(try result.get())))
                } catch {
                    single(.error(error))
                }
            }
            return Disposables.create { }
        }.asObservable()
    }

    public func clearCache() -> Observable<Void> {
        return Single.create { single in
            self.base.clearMemoryCache()
            self.base.clearDiskCache(completion: {
                single(.success(()))
            })
            return Disposables.create { }
        }.asObservable()
    }
}
