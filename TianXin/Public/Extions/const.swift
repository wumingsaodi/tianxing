//
//  const.swift
//  TianXin
//
//  Created by SDS on 2020/9/17.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
func scaleX(_ f:CGFloat)->CGFloat {
    return f * (Configs.Dimensions.screenWidth / 375.0)
}
let KScreenW = UIScreen.main.bounds.width
let KScreenH = UIScreen.main.bounds.height
let kStatueH = UIApplication.shared.statusBarFrame.size.height
let KnavHeight  = kStatueH + 44
let kbottomtoolBar = kBottomSafeH + 44
let kBottomSafeH :CGFloat =  kStatueH > 20 ? 34 : 0
let mainYellowColor:UIColor = .Hex("#FCB65D")
let mainYellowGradienImg = UIImage.CreateGradienImg(colors: [.init(hex: 0xFFD26B),.init(hex: 0xF8944B)])
let baseVCBackGroudColor_grayWhite:UIColor = .Hex("#FFF7F8FC")
func getUUID()->String{
    return UIDevice.current.identifierForVendor!.uuidString
}

func NJLog<T>(_ message: T, fileName: String = #file, methodName: String = #function, lineNumber: Int = #line)
{
    #if DEBUG
    // 要把路径最后的字符串截取出来
    let fName = ((fileName as NSString).pathComponents.last!)
    print("\(fName).\(methodName)[\(lineNumber)]: \(message)")
    #endif
}

/**
 frame
 */
extension UIView {
    var sdsSize:CGSize{
        set{
            self.bounds.size = newValue
        }
        get{
            return self.bounds.size
        }
    }
    var sdsH:CGFloat{
        set{
            self.sdsSize = CGSize(width: self.sdsSize.width, height: newValue)
        }
        get{
            return self.sdsSize.height
        }
    }
    var sdsW:CGFloat{
        set{
            self.sdsSize = CGSize(width: newValue, height: sdsSize.height)
        }
        get{
            return sdsSize.width
        }
    }
    var sdsOrigin:CGPoint {
        set{
            self.frame.origin = newValue
        }
        get{
            return self.frame.origin
        }
    }
    var sdsX:CGFloat {
        set{
            sdsOrigin = CGPoint(x: newValue, y: sdsOrigin.y)
        }
        get {
            return sdsOrigin.x
        }
    }
    var sdsY:CGFloat {
           set{
               sdsOrigin = CGPoint(x: sdsX, y: newValue)
           }
           get {
               return sdsOrigin.y
           }
       }
    var sdsRightX:CGFloat{
        set{
            sdsOrigin  = CGPoint(x: newValue - sdsW, y: sdsOrigin.y)
        }
        get{
            return sdsOrigin.x + sdsW
        }
    }
    var sdsBottonY:CGFloat {
        set{
            sdsOrigin = CGPoint(x: sdsOrigin.x, y: newValue - sdsH)
        }
        get{
            return  sdsW + sdsY
        }
    }
//    var sdsCenterY:CGFloat {
//        set{
//            self.center.y = newValue
//        }
//        get{
//            return
//        }
//    }
}

extension NSObject {
//  static  struct performAssociatedKey {
//
//    }
  static  var sdsPerformBlockKey  = "sdsPerformBlockKey"
    var sdsPerformBlock:()->Void{
        set{
            objc_setAssociatedObject(self, &NSObject.sdsPerformBlockKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get{
            objc_getAssociatedObject(self, &NSObject.sdsPerformBlockKey) as! () -> Void
        }
    }
    func perform(block:@escaping ()->Void,timel:TimeInterval){
//        self.sdsPerformBlock = block
        Timer.scheduledTimer(withTimeInterval: timel, repeats: false) { (_) in
            block()
        }
//        self.perform(#selector(sdsPerformAction), with: nil, afterDelay: timel)
    }
  @objc func sdsPerformAction(){
        self.sdsPerformBlock()
    }
}
public extension DispatchQueue {

    private static var _onceTracker = [String]()

    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.

     - parameter token: A unique reverse DNS style name such as com.vectorform. or a GUID
     - parameter block: Block to execute once
     */
    class func once(token: String, block:()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        if _onceTracker.contains(token) {
            return
        }

        _onceTracker.append(token)
        block()
    }
}
import SnapKit
