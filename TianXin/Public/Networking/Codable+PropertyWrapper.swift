//
//  Codable+PropertyWrapper.swift
//  TianXin
//
//  Created by pretty on 10/23/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation


@propertyWrapper
class BetterCodable<Value>{
    var wrappedValue: Value
    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

// MARK: - better bool decode
// 【历史批注】接口bool字段可能会返回整形、字符串、数组、对象
@propertyWrapper
struct BetterBoolCodable: Codable {
    struct DictionaryCodingKey: CodingKey {
        let stringValue: String
        let intValue: Int?
        init?(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = Int(stringValue)
        }
        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }

    }
    var wrappedValue: Bool
    init(wrappedValue: Bool) {
        self.wrappedValue = wrappedValue
    }

    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: DictionaryCodingKey.self),
           !container.allKeys.isEmpty {
            self.wrappedValue = true
        }  else if let container = try? decoder.unkeyedContainer() {
            self.wrappedValue = container.count != 0
        } else if let container = try? decoder.singleValueContainer() {
            if let string = try? container.decode(String.self) {
                self.wrappedValue = string == "1"
            } else if let int = try? container.decode(Int.self) {
                self.wrappedValue = int == 1
            } else if let bool = try? container.decode(Bool.self) {
                self.wrappedValue = bool
            } else {
                self.wrappedValue = false
            }
        } else  {
            self.wrappedValue = false
        }
    }
    func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}


