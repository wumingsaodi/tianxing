//
//  String+add.swift
//  TianXin
//
//  Created by SDS on 2020/9/18.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

extension String{
    public subscript(loc:Int) -> String {
         let startIndex = self.index(self.startIndex, offsetBy: loc)
        return String(self[startIndex..<self.endIndex])
    }
    public subscript(loc:Int,lenth:Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: loc)
        let endIndex = self.index(self.startIndex, offsetBy: loc + lenth)
        return String(self[startIndex..<endIndex])
    }
    func rangeOfText(text:String)->NSRange?{
        let range1 =  self.range(of: text)
        guard let range = range1 else {
            return nil
        }
        let loc = self.distance(from: self.startIndex, to: range.lowerBound)
        let lenth = self.distance(from: range.lowerBound, to: range.upperBound)
        return NSMakeRange(loc, lenth)
    }
    func setAttrStr(loc:Int,lenth:Int,color:UIColor,font:UIFont)->NSAttributedString{
        let attrStr = NSMutableAttributedString(string: self)
        let range = NSMakeRange(loc, lenth)
        attrStr.addAttributes([NSAttributedString.Key.foregroundColor : color,NSAttributedString.Key.font:font], range: range)
        return attrStr
    }
    func setAttrStr(text:String,color:UIColor,font:UIFont)->NSAttributedString? {
        let range1 =  self.range(of: text)
        guard let range = range1 else {
            return nil
        }
        let loc = self.distance(from: self.startIndex, to: range.lowerBound)
        let lenth = self.distance(from: range.lowerBound, to: range.upperBound)
        return setAttrStr(loc: loc, lenth: lenth, color: color,font: font)
    }
}
extension NSAttributedString {
    func addAttr(loc:Int,lenth:Int,color:UIColor,font:UIFont)->NSAttributedString{
        let attrStr = NSMutableAttributedString(attributedString: self)
               let range = NSMakeRange(loc, lenth)
               attrStr.addAttributes([NSAttributedString.Key.foregroundColor : color,NSAttributedString.Key.font:font], range: range)
               return attrStr
    }
    func addAttrStr(text:String,color:UIColor,font:UIFont)->NSAttributedString? {
        let range1 =  self.string.range(of: text)
        guard let range = range1 else {
            return nil
        }
        let loc = self.string.distance(from: self.string.startIndex, to: range.lowerBound)
        let lenth = self.string.distance(from: range.lowerBound, to: range.upperBound)
        return addAttr(loc: loc, lenth: lenth, color: color,font: font)
    }
}
