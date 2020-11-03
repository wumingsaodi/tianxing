//
//  JSON.swift
//  TianXin
//
//  Created by pretty on 10/7/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation

@dynamicMemberLookup
enum JSON {
    case dictionary([String: JSON])
    case array([JSON])
    case string(String)
    case number(NSNumber) // int float double decimal...
    case bool(Bool)
    case null
    
    subscript(dynamicMember member: String) -> JSON {
        if case .dictionary(let dict) = self {
            return dict[member] ?? .null
        }
        return .null
    }
    subscript(index: Int) -> JSON {
        if case .array(let arr) = self {
            return index < arr.count ? arr[index] : .null
        }
        return .null
    }
    subscript(key: String) -> JSON {
        if case .dictionary(let dict) = self {
            return dict[key] ?? .null
        }
        return .null
    }
    // init
    init(_ object: Any) {
        switch object {
        case let data as Data:
            if let converted = try? JSON(data: data) {
                self = converted
            } else {
                self = .null
            }
        case let dictionary as [String: Any]:
            self = JSON.dictionary(dictionary.mapValues{ JSON($0) })
        case let array as [Any]:
            self = JSON.array(array.map{ JSON($0) })
        case let string as String:
            self = JSON.string(string)
        case let number as NSNumber:
            self = JSON.number(number)
        case let bool as Bool:
            self = JSON.bool(bool)
        case let json as JSON:
            self = json
        default:
            self = .null
        }
    }
    init(data: Data, options: JSONSerialization.ReadingOptions = .allowFragments) throws {
        let object = try JSONSerialization.jsonObject(with: data, options: options)
        self = JSON(object)
    }
    // get value
    var dictionary: [String: JSON] {
        if case .dictionary(let value) = self {
            return value
        }
        return [:]
    }
    var array: [JSON] {
        if case .array(let value) = self {
            return value
        }
        return []
    }
    var string: String {
        switch self {
        case .string(let v):
            return v
        case .number(let v):
            return v.stringValue
        default:
            return ""
        }
    }
    var number: NSNumber? {
        switch self {
        case .number(let value):
            return value
        case .bool(let value):
            return NSNumber(value: value)
        case .string(let value):
            if let doubleValue = Double(value) {
                return NSNumber(value: doubleValue)
            }
            return nil
        default:
            return nil
        }
    }
    var double: Double {
        return number?.doubleValue ?? 0.0
    }
    var int: Int {
        return number?.intValue ?? 0
    }
    var bool: Bool {
        switch self {
        case .bool(let v):
            return v
        case .number(let v):
            return v.boolValue
        default:
            return false
        }
    }
    var object: Any {
        switch self {
        case .dictionary(let v): return v.mapValues { $0.object }
        case .array(let v): return v.map { $0.object }
        case .string(let v): return v
        case .number(let v): return v
        case .bool(let v): return v
        case .null: return NSNull()
            
        }
    }
    func data(options: JSONSerialization.WritingOptions = []) -> Data {
        return (try? JSONSerialization.data(withJSONObject: self.object, options: options)) ?? Data()
    }
}
extension JSON: Swift.CustomStringConvertible, Swift.CustomDebugStringConvertible {
    
    public var description: String {
        return String(describing: self.object as AnyObject).replacingOccurrences(of: ";\n", with: "\n")
    }
    public var debugDescription: String {
        return description
    }
}

extension JSON: Comparable {
    public static func == (lhs: JSON, rhs: JSON) -> Bool {
        switch (lhs, rhs) {
        case (.dictionary, .dictionary): return lhs.dictionary == rhs.dictionary
        case (.array, .array): return lhs.array == rhs.array
        case (.string, .string): return lhs.string == rhs.string
        case (.number, .number): return lhs.number == rhs.number
        case (.bool, .bool): return lhs.bool == rhs.bool
        case (.null, .null): return true
        default: return false
        }
    }
    public static func < (lhs: JSON, rhs: JSON) -> Bool {
        switch (lhs, rhs) {
        case (.string, .string):
            return lhs.string < rhs.string
        case (.number, .number):
            if let lhsNumber = lhs.number, let rhsNumber = rhs.number {
                return lhsNumber.doubleValue < rhsNumber.doubleValue
            }
            return false
        default: return false
        }
    }
}
