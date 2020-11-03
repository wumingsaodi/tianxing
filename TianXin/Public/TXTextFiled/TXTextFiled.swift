//
//  TXTextFiled.swift
//  TianXin
//
//  Created by admin on 2020/11/2.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class TXTextField: UITextField {

    /// 文本的的内边距, 也就是距离上左下右的边距
    var textInsets: UIEdgeInsets?
    
    // MARK: - Override Function
        /**
         * 占位符位置和大小的重写
         * Parameter bounds: 改变之前的位置和大小
         * Returns: 改变之后的位置和大小
         */
        override func textRect(forBounds bounds: CGRect) -> CGRect {
            var rect = bounds
            if let insets = self.textInsets {
                rect.origin.x += insets.left
                rect.origin.y += insets.top
                rect.size.width -= (insets.left + insets.right)
                rect.size.height -= (insets.top + insets.bottom)
            }
            return super.textRect(forBounds: rect)
        }
        
        /**
         * 文本位置和大小的重写
         * Parameter bounds: 改变之前的位置和大小
         * Returns: 改变之后的位置和大小
         */
        override func editingRect(forBounds bounds: CGRect) -> CGRect {
            var rect = bounds
            if let insets = self.textInsets {
                rect.origin.x += insets.left
                rect.origin.y += insets.top
                rect.size.width -= (insets.left + insets.right)
                rect.size.height -= (insets.top + insets.bottom)
            }
            return super.textRect(forBounds: rect)
        }

}
