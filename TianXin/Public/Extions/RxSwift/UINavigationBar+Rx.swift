//
//  UINavigationBar+Rx.swift
//  TianXin
//
//  Created by pretty on 10/9/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

extension Reactive where Base: UINavigationBar {
    var alpha: Binder<CGFloat> {
        return Binder<CGFloat>(self.base) {
            bar, alpha in
            let pAlhpa = min(max(0, alpha), 1)
            let image =  try? UIImage(color: .init(white: 1, alpha: pAlhpa))
            bar.setBackgroundImage(image, for: .default)
            bar.subviews.forEach { $0.alpha = pAlhpa }
            bar.shadowImage = UIImage()
        }
    }
}
