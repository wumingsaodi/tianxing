//
//  UICollectionView+.swift
//  TianXin
//
//  Created by pretty on 10/8/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

extension UICollectionView {
      func registerClass<T:UICollectionViewCell>(type:T.Type) {
        register(type, forCellWithReuseIdentifier: "\(type)")
    }
    func registerNib<T: UICollectionViewCell>(type: T.Type) {
        register(UINib(nibName: "\(type)", bundle: nil), forCellWithReuseIdentifier: "\(type)")
    }
    func registerHeaderClass<T: UICollectionReusableView>(type: T.Type) {
        register(type, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "\(type)")
    }
    func registerHeaderSupplementaryViewNib<T: UICollectionReusableView>(type: T.Type) {
        register(UINib(nibName: "\(type)", bundle: nil),
                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                      withReuseIdentifier: "\(type)")
    }
    func registerFooterSupplementaryViewNib<T: UICollectionReusableView>(type: T.Type) {
        register(UINib(nibName: "\(type)", bundle: nil),
                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                      withReuseIdentifier: "\(type)")
    }
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: "\(T.self)", for: indexPath) as! T
    }
    func dequeueReusableHeaderView<T: UICollectionReusableView>(for indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(T.self)",
            for: indexPath
        ) as! T
    }
    func dequeueReusableFooterView<T: UICollectionReusableView>(for indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "\(T.self)",
            for: indexPath
        ) as! T
    }
}

