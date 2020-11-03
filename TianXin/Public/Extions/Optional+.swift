//
//  Optional+.swift
//  TianXin
//
//  Created by pretty on 10/7/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation

extension Optional where Wrapped == String {
    var isEmpty: Bool {
        switch self {
        case .none:
            return true
        case .some(let string):
            return string.isEmpty
        }
    }
}

extension Optional where Wrapped: Collection {
    var isEmpty: Bool {
        switch self {
        case .none: return false
        case .some(let array): return array.isEmpty
        }
    }
}

extension Optional where Wrapped == Int {
    static func += ( left: inout Self, right: Int) {
        switch left {
        case .none:
            left = right
        case .some(let v):
            left = v + right
        }
    }
    static func -= (left: inout Self, right: Int) {
        switch left {
        case .none:
            left = -right
        case .some(let v):
            left = v - right
        }
    }
    static func + (left: Self, right: Int) -> Int {
        switch left {
        case .none:
            return right
        case let .some(v):
            return v + right
        }
    }
    static func - (left: Self, right: Int) -> Int {
        switch left {
        case .none:
            return -right
        case let .some(v):
            return v - right
        }
    }
}
