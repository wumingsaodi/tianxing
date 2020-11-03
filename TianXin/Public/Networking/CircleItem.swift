//
//  Circle.swift
//  TianXin
//
//  Created by pretty on 10/15/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation

struct CircleItem: Codable {
    var recommendId: Int64
    var recommendUserNum: Int?
    var recommendTZNum: Int?
    var recommendPic: String?
    var recommendName: String?
    var recommendDesc: String?
    @BetterBoolCodable var isJoin: Bool
}

extension CircleItem {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        recommendId = try container.decode(Int64.self, forKey: CodingKeys.recommendId)
        recommendUserNum = try? container.decode(Int?.self, forKey: CodingKeys.recommendUserNum)
        recommendTZNum = try? container.decode(Int?.self, forKey: CodingKeys.recommendTZNum)
        recommendPic = try? container.decode(String?.self, forKey: CodingKeys.recommendPic)
        recommendName = try? container.decode(String?.self, forKey: CodingKeys.recommendName)
        recommendDesc = try? container.decode(String?.self, forKey: CodingKeys.recommendDesc)
        if !container.contains(CodingKeys.isJoin) {
            isJoin = false
        } else {
            let optionalBool = try container.decode(BetterBoolCodable.self, forKey: CodingKeys.isJoin)
            isJoin = optionalBool.wrappedValue
        }
    }
}

