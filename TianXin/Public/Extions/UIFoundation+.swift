//
//  UIFoundation+.swift
//  TianXin
//
//  Created by pretty on 10/9/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation

extension Int {
    var unitCountString: String {
        if self < 1000 {
            return "\(self)"
        }
        if self < 10000 {
            return String(format: "%.2f千", Double(self) / 1000)
        }
        return String(format: "%.2f万", Double(self) / 10000)
    }
    
    func toString() -> String {
        return "\(self)"
    }
}

extension Array {
    static func * (left: Self, right: Int) -> Self {
        var arr = [] as Self
        for _ in 0 ..< right {
            arr.append(contentsOf: left)
        }
        return arr
    }
}

extension String {
    static func * (left: Self, right: Int) -> Self {
        var string = ""
        for _ in 0 ..< right {
            string += left
        }
        return string
    }
}
