//
//  UITextField+.swift
//  TianXin
//
//  Created by pretty on 10/10/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

extension UITextField {
    func setPlaceholder(font: UIFont, color: UIColor) {
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [
            .font: font,
            .foregroundColor: color
        ])
    }
}
