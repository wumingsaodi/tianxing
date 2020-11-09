//
//  UIView+extion.swift
//  TianXin
//
//  Created by SDS on 2020/9/17.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
extension NSObject {
  static  func className() -> String {
    return self.description()//.components(separatedBy: ".").last!
    }
}



/**
UIView
*/

extension UIView{
    
    static func xib(xibName:String) -> UIView {
        let nib = UINib.init(nibName: xibName, bundle: nil)
        
        let vw = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return vw
    }
    func getViewController()->UIViewController? {
        var response = self as UIResponder
        while  response.next != nil {
            if response.isKind(of: UIViewController.self){
                return (response as! UIViewController)
            }
            response  = response.next!
        }
        return nil
    }
    @objc  func MylayoutSubviews() {
//        NJLog("\(self)")
        self.MylayoutSubviews()
        setlayoutForCorner()
    }
    struct AssociateKeys {
        static var sdspreCover = "sdspreCover"
    }
    private var preCover:CAShapeLayer?{
        set{
            objc_setAssociatedObject(self, &AssociateKeys.sdspreCover, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            return objc_getAssociatedObject(self, &AssociateKeys.sdspreCover) as? CAShapeLayer
        }
    }
    @objc fileprivate  func  setlayoutForCorner() {
                if self.sdsCornorReduis != nil {
                    let path = UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners: self.sdsCornorType ?? .allCorners, cornerRadii: CGSize(width: self.sdsCornorReduis!, height: self.sdsCornorReduis!))
//                 let path =    UIBezierPath.init(roundedRect: self.bounds, cornerRadius: self.sdsCornorReduis!)
                    if self.sdsBorderWith != nil {
                        path.lineWidth = sdsBorderWith!
            
                    }
                    let maskLayer = CAShapeLayer()
                    maskLayer.path = path.cgPath
                    if (self.sdsBorderColor != nil) {
                        maskLayer.strokeColor = self.sdsBorderColor?.cgColor
                    }
                    self.layer.mask = maskLayer
                    if self.sdsBorderWith != nil {
                        if preCover != nil {
                            preCover?.removeFromSuperlayer()
                        }
                        let cover = CAShapeLayer()
                        cover.path = path.cgPath
                        cover.fillColor = UIColor.clear.cgColor
                        cover.strokeColor = sdsBorderColor?.cgColor
                        self.layer.addSublayer(cover)
                        preCover = cover
                    }
                   
        //
                }
    }
    static var awakeName = {
      
    }
    class func awake() {
        let m1 = class_getInstanceMethod(self, NSSelectorFromString("layoutSubviews"))
        let m2 = class_getInstanceMethod(self, #selector(MylayoutSubviews))
        method_exchangeImplementations(m1!, m2!)
    }
    private struct AssociatedKeys {
        static var cornorReduis = "sdsCornorWith"
        static var conorType = "sdsConorType"
        static var borderWith = "sdsBorderWith"
       static var borderColor = "sdsBorderColor"
    }    
 open  func cornor(conorType:UIRectCorner,reduis:CGFloat,borderWith:CGFloat? = nil,borderColor:UIColor? = nil){
        
        self.sdsBorderWith = borderWith
        self.sdsBorderColor = borderColor
        self.sdsCornorReduis = reduis
        self.sdsCornorType = conorType
      setNeedsLayout()
      layoutIfNeeded()
//        if self.isKind(of: UIButton.self) {
//            self.layer.cornerRadius = reduis
//            self.layer.masksToBounds = true
//            if borderWith != nil {
//                self.layer.borderWidth = borderWith!
//            }
//            if borderColor != nil {
//                self.layer.borderColor = borderColor!.cgColor
//            }
//
//          }
    }
    var sdsCornorReduis:CGFloat?{
        set{
//            if newValue != nil {
                objc_setAssociatedObject(self, &AssociatedKeys.cornorReduis, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            }
            
        }
        get{
//         let value =    objc_getAssociatedObject(self, &AssociatedKeys.cornorReduis)
//            return value as? CGFloat
            return  objc_getAssociatedObject(self, &AssociatedKeys.cornorReduis) as? CGFloat
        }
    }
    var sdsCornorType:UIRectCorner?{
        set{
            if newValue != nil {
                 objc_setAssociatedObject(self, &AssociatedKeys.conorType, newValue!, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
           
        }
        get{
            objc_getAssociatedObject(self, &AssociatedKeys.conorType) as? UIRectCorner
        }
    }
    var sdsBorderWith:CGFloat?{
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.borderWith, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get{
         return   objc_getAssociatedObject(self, &AssociatedKeys.borderWith) as? CGFloat
        }
    }
    var sdsBorderColor:UIColor?{
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.borderColor, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get{
            return  objc_getAssociatedObject(self, &AssociatedKeys.borderColor) as? UIColor
        }
    }
}

/**
 UIbutton
 */
enum SDSButtonType:Int {
     case imgLeft = 0;
    case imgTop = 1;
    case imgRight = 2 ;
   
}
class SDSButton: UIButton {
    var boundsPadding:UIEdgeInsets = .zero
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.titleRect(forContentRect: contentRect)
        var newrect = rect
        if self.butType == .imgTop{
//            let nsStr = (self.currentTitle ?? "")as NSString
//            let textrectWidth =  nsStr.boundingRect(with: contentRect.size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : self.titleLabel?.font as Any], context: nil).size.width
           
            newrect =  CGRect(origin: newrect.origin, size: CGSize(width: contentRect.size.width, height: newrect.size.height))
        }
       
        return newrect
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        setlayoutForCorner()
    }
}
extension UIButton {
    private struct AssociatedKeys {
        static var sel = "sdsSel"
        static var butType = "sdsButType"
        static var butPadding = "sdsButPadding"
    }
    private var sdsSel:((_ but:UIButton)->Void)?{
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.sel, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            return objc_getAssociatedObject(self, &AssociatedKeys.sel) as? ((_ but:UIButton)->Void)
        }
    }
    
    static func createButWith(title:String? = nil,titleColor:UIColor? = nil,font:UIFont? = nil,image:UIImage? = nil,backGroudImg:UIImage? = nil,backGroudColor:UIColor? = nil,boundsPadding:UIEdgeInsets   = .zero,eventType:UIControl.Event? = .touchUpInside,sel: ((_ but:UIButton)->Void)? = nil)-> UIButton{
         let  but = SDSButton()
        but.setTitle(title, for: .normal)
        but.setTitleColor(titleColor, for: .normal)
        if font != nil {
            but.titleLabel?.font = font
        }
        but.setImage(image, for: .normal)
        but.setBackgroundImage(backGroudImg, for: .normal)
        but.backgroundColor = backGroudColor
        but.boundsPadding = boundsPadding
        but.contentEdgeInsets = boundsPadding
        if sel != nil {
            but.sdsSel = sel
            but.addTarget(but, action: #selector(SDSButClick(but:)), for: eventType!)
        }
        
        return but
    }
    @objc private func SDSButClick(but:UIButton){
        if but.sdsSel != nil {
            but.sdsSel!(self)
        }
    }
    func setButType(type:SDSButtonType,padding:CGFloat?){
        self.butType = type
        self.butPadding = padding ?? 0
        self.perform(#selector(sdslayout), with: nil, afterDelay: 0.15)
        
    }
    @IBInspectable var butPadding:CGFloat{
           set{
               objc_setAssociatedObject(self, &AssociatedKeys.butPadding, newValue, .OBJC_ASSOCIATION_ASSIGN)
            self.perform(#selector(sdslayout), with: nil, afterDelay: 0.15)
           }
           get{
            return (objc_getAssociatedObject(self, &AssociatedKeys.butPadding) as? CGFloat) ?? 0
           }
       }
    var butType:SDSButtonType?{
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.butType, newValue?.rawValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get{
            let value =  objc_getAssociatedObject(self, &AssociatedKeys.butType) as? Int
            return SDSButtonType(rawValue: value ?? 0 )
        }
    }
//    open override func didMoveToSuperview() {
//        self.perform(#selector(layoutSubviews), with: nil, afterDelay: 3)
//    }

    @objc func sdslayout() {
        self.setNeedsUpdateConstraints()
        self.updateConstraintsIfNeeded()
          self.setNeedsLayout()
          self.layoutIfNeeded()
      
        
        if self.butType != nil {
            let labWidth:CGFloat = (self.titleLabel?.bounds.size.width)!
            let labHeight:CGFloat = (self.titleLabel?.bounds.size.height)!
            let imgWidth:CGFloat = (self.imageView?.bounds.size.width)!
            let imgHeight:CGFloat = (self.imageView?.bounds.size.height)!
            let padding:CGFloat = self.butPadding 
            switch self.butType {
            case .imgTop:
                
//                self.imageEdgeInsets = UIEdgeInsets(top: -labHeight*0.5 - padding*0.5, left: (sdsW - imgWidth) * 0.5, bottom: labHeight*0.5 + padding*0.5, right: -(sdsW - imgWidth) * 0.5)
               
                if #available(iOS 13.0, *) {
                    self.imageEdgeInsets = UIEdgeInsets(top: -labHeight*0.5 - padding*0.5, left: (sdsW - imgWidth) * 0.5, bottom: labHeight*0.5 + padding*0.5, right: -(sdsW - imgWidth) * 0.5)
                } else {
//                    self.imageView?.frame.origin = CGPoint(x: (self.sdsW - imgWidth)*0.5, y:  imageView?.frame.origin.y ?? 0)
                    let lettRightMargin = (self.sdsW - imgWidth - (imageView?.sdsX ?? 0))/2
                    self.imageEdgeInsets = UIEdgeInsets(top: -labHeight*0.5 - padding*0.5, left: lettRightMargin, bottom: labHeight*0.5 + padding*0.5, right: -lettRightMargin)
                }
//                self.imageEdgeInsets = UIEdgeInsets(top: -labHeight*0.5 - padding*0.5, left: 0 , bottom: labHeight*0.5 + padding*0.5, right: 0)
              
                self.titleEdgeInsets = UIEdgeInsets(top: imgHeight*0.5 + padding*0.5, left: -imgWidth, bottom: -imgHeight*0.5 - padding*0.5, right: (sdsW - labWidth))
                break
            case .imgRight:
                self.imageEdgeInsets = UIEdgeInsets(top: 0, left: labWidth+padding*0.5, bottom: 0, right:-labWidth-padding*0.5)
                self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imgWidth-padding*0.5, bottom: 0, right: imgWidth+padding*0.5)
                break
            case .imgLeft:
                self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -padding*0.5, bottom: 0, right:padding*0.5)
                self.titleEdgeInsets = UIEdgeInsets(top: 0, left: padding*0.5, bottom: 0, right: -padding*0.5)
                break
                    
            default:
                break
            }

        }
    }
}
class  SDSPaddingLabal: UILabel {

    var padding:UIEdgeInsets = .zero
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        if padding == .zero {
            return super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        }
        let rect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        let  newrect = CGRect(origin: CGPoint(x: rect.origin.x + padding.left, y: rect.origin.y + padding.top) , size: CGSize(width: rect.width + padding.left + padding .right, height: rect.height + padding.top + padding.bottom))
      return newrect
    }
    override func draw(_ rect: CGRect) {
          if padding == .zero {
            return super.draw(rect)
        }
        if #available(iOS 13.0, *) {
            super.drawText(in:rect.inset(by: padding))
        }else{
            let myrect = CGRect(origin: CGPoint(x: 0, y: rect.origin.y), size: rect.size)
            let  newRect =  myrect.inset(by: padding) //myrect.inset(by: UIEdgeInsets(top: 0, left:
            super.drawText(in:newRect)
        }
     
    }
}
extension UILabel {
    
    static func createLabWith(title:String? = nil,titleColor:UIColor? = nil,font:UIFont? = nil,aligment:NSTextAlignment  = .left,backGroudColor:UIColor? = nil, cornorRaduis:CGFloat? = nil,cornorType:UIRectCorner? = nil,borderWith:CGFloat? = nil,borderColor:UIColor? = nil,padding:UIEdgeInsets? = nil)->UILabel{
       let lab = SDSPaddingLabal()
        lab.text = title
        if titleColor != nil {
            lab.textColor = titleColor!
        }
        if font != nil {
            lab.font = font!
        }
        lab.textAlignment = aligment
        if cornorRaduis != nil && cornorType != nil {
            lab.cornor(conorType: cornorType!, reduis: cornorRaduis!, borderWith: borderWith, borderColor: borderColor)
        }
        if padding != nil {
            lab.padding = padding!
        }
        if backGroudColor != nil{
            lab.backgroundColor = backGroudColor
        }
        
        return lab
    }
}
