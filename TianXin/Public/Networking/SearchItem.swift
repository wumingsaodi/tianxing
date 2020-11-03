//
//  SearchItem.swift
//  TianXin
//
//  Created by pretty on 10/10/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import Foundation

struct SearchItem: Codable, Hashable {
    var id: Int
    var content: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.content ?? "")
    }
    static func == (lhs: SearchItem, rhs: SearchItem) -> Bool {
        return lhs.content == rhs.content
    }
}
