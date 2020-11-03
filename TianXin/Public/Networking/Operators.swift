//
//  Operators.swift
//  TianXin
//
//  Created by pretty on 10/10/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation

enum BytesSizeCapacity {
    case K, M, G, T
}
let Kb = BytesSizeCapacity.K
let Mb = BytesSizeCapacity.M
let Gb = BytesSizeCapacity.G
let Tb = BytesSizeCapacity.T

precedencegroup BytesSizePrecedence {
    associativity: left
    higherThan: MultiplicationPrecedence
}

infix operator ^: BytesSizePrecedence

func ^ (left: Int, right: BytesSizeCapacity) -> Int {
    switch right {
    case .K:
        return left * 1024
    case .M:
        return left^Kb * 1024
    case .G:
        return left^Mb * 1024
    case .T:
        return left^Tb * 1024
    }
}
