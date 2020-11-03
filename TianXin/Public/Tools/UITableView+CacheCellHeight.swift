//
//  UITableView+CacheCellHeight.swift

import Foundation
import UIKit

private var __hyb_cache_cell_heigh_for_row_key = "__hyb_cache_cell_heigh_for_row"
private var __hyb_cache_cell_calheigh_for_row_key = "__hyb_cache_cell_calheigh_for_row_key"

///
/// 基于SnapKit扩展自动计算cell的高度
///
extension UITableView {
  public var hyb_cacheHeightDictionary: NSMutableDictionary? {
    get {
      let dict = objc_getAssociatedObject(self,
        &__hyb_cache_cell_heigh_for_row_key) as? NSMutableDictionary;
      
      if let cache = dict {
        return cache;
      }
      
      let newDict = NSMutableDictionary()
      
      objc_setAssociatedObject(self,
        &__hyb_cache_cell_heigh_for_row_key,
        newDict,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      
      return newDict
    }
  }
  
  public var hyb_cacheCellDictionary: NSMutableDictionary? {
    get {
      let dict = objc_getAssociatedObject(self,
        &__hyb_cache_cell_calheigh_for_row_key) as? NSMutableDictionary;
      
      if let cache = dict {
        return cache;
      }
      
      let newDict = NSMutableDictionary()
      
      objc_setAssociatedObject(self,
        &__hyb_cache_cell_calheigh_for_row_key,
        newDict,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      
      return newDict
    }
  }
}
