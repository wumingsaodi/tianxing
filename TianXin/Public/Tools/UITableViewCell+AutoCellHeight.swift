//
//  UITableView+AutoCellHeight.swift

import Foundation
import UIKit
import SnapKit

private var __hyb_lastViewInCellKey  = "__hyb_lastViewInCellKey"
private var __hyb_bottomOffsetToCell = "__hyb_bottomOffsetToCell"

///
/// 基于SnapKit扩展自动计算cell的高度
private let __currentVersion = "1.0"

extension UITableViewCell {
  /// 所指定的距离cell底部较近的参考视图，必须指定，若不指定则会assert失败
  public var hyb_lastViewInCell: UIView? {
    get {
      let lastView = objc_getAssociatedObject(self, &__hyb_lastViewInCellKey);
      return lastView as? UIView
    }
    
    set {
      objc_setAssociatedObject(self,
        &__hyb_lastViewInCellKey,
        newValue,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
  }
  
  /// 可不指定，若不指定则使用默认值0
  public var hyb_bottomOffsetToCell: CGFloat? {
    get {
      let offset = objc_getAssociatedObject(self, &__hyb_bottomOffsetToCell);
      return offset as? CGFloat
    }
    
    set {
      objc_setAssociatedObject(self,
        &__hyb_bottomOffsetToCell,
        newValue,
        .OBJC_ASSOCIATION_ASSIGN);
    }
  }
  
  /**
   带缓存功能、自动计算行高
   
   - parameter tableView:					给哪个tableview缓存
   - parameter config:						在回调中配置数据
   - parameter cache:							指定缓存key/stateKey/tableview
   - parameter stateKey:					stateKey表示状态key
   - parameter shouldUpdate       是否要更新指定stateKey中缓存高度，若为YES,不管有没有缓存 ，都会重新计算
   
   - returns: 行高
   */
  public class func hyb_cellHeight(forTableView tableView: UITableView,
                                   config: ((_ cell: UITableViewCell) -> Void)?,
                                   updateCacheIfNeeded cache: (() -> (key: String, stateKey: String, shouldUpdate: Bool))?) -> CGFloat {
    var isNeedUpdate:Bool = true
      if let cacheBlock = cache {
        let keyGroup = cacheBlock()
        let key = keyGroup.key
        let stateKey = keyGroup.stateKey
        let shouldUpdate = keyGroup.shouldUpdate;
        isNeedUpdate = shouldUpdate
        if shouldUpdate == false {
          if  let cacheDict = tableView.hyb_cacheHeightDictionary {
            // 状态高度缓存
            if let stateDict = cacheDict[key] as? NSMutableDictionary {
                print("缓存的key:\(key)")
              if let height = stateDict[stateKey] as? NSNumber {
                if height.intValue != 0 {
                  return CGFloat(height.floatValue)
                }
              }
            } else {
                print("没有缓存的key:\(key)")
            }
          }
        }else {
            
        }
      }
      
        let className = String(utf8String: class_getName(self))
//      let className = String(UTF8String: class_getName(self));
    var cell = tableView.hyb_cacheCellDictionary?.object(forKey: className!) as? UITableViewCell;
      
      if cell == nil {
        cell = self.init(style: .default, reuseIdentifier: nil)
        tableView.hyb_cacheCellDictionary?.setObject(cell!, forKey: className! as NSCopying);
      }
    if  isNeedUpdate {
        if let block = config {
          block(cell!);
        }
    }
    
      
      return cell!.hyb_calculateCellHeight(forTableView: tableView, updateCacheIfNeeded: cache)
  }
  
  // Mark - Private
  private func hyb_calculateCellHeight(forTableView tableView: UITableView,
    updateCacheIfNeeded cache: (() -> (key: String, stateKey: String, shouldUpdate: Bool))?) -> CGFloat {
      assert(self.hyb_lastViewInCell != nil, "hyb_lastViewInCell property can't be nil")
//    [self setNeedsUpdateConstraints];
//    [self updateConstraintsIfNeeded];
//
//    [self setNeedsLayout];
//    [self layoutIfNeeded];

    self.setNeedsUpdateConstraints()
    self.updateConstraintsIfNeeded()
    
    self.setNeedsLayout()
    self.layoutIfNeeded()
    
    print("最后一个view是\(self.hyb_lastViewInCell!)")

    print("最后一个view的Y是\(self.hyb_lastViewInCell!.frame.origin.y)")
    print("最后一个view的高度是\(self.hyb_lastViewInCell!.frame.size.height)")
      var height = self.hyb_lastViewInCell!.frame.origin.y + self.hyb_lastViewInCell!.frame.size.height;
      height += self.hyb_bottomOffsetToCell ?? 0.0
      
      if let cacheBlock = cache {
        let keyGroup = cacheBlock()
        let key = keyGroup.key
        let stateKey = keyGroup.stateKey
        
        if let cacheDict = tableView.hyb_cacheHeightDictionary {
          // 状态高度缓存
          let stateDict = cacheDict[key] as? NSMutableDictionary
          
          if stateDict != nil {
            stateDict?[stateKey] = NSNumber(value: Float(height))
          } else {
            cacheDict[key] = NSMutableDictionary(object: NSNumber(value: Float(height)), forKey: stateKey as NSCopying)
          }
        }
      }
      
      return height
  }
}

