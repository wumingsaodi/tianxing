//
//  SDSCodeView.swift
//  TianXin
//
//  Created by SDS on 2020/9/28.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class SDSCodeView: UIView {
    
    private var codeStrs:[String] = [String]()
    var codeNum:Int = 4
    /**
     网络请求需要的
     */
    var refreshBlock:((_ fishishBlock:(_ tites:String)->Void)->Void)? {
        didSet{
            if let block = self.refreshBlock {
                block({[weak self] (titles) in
                    self?.requistFinished(titles: titles)
                })
            }
        }
    }
    private   var klineNum:Int = 4
    var sdsCodeStr:String {
        var temp = ""
        for sub in codeStrs {
            temp.append(sub)
        }
        return temp
    }
    func refresh()  {
        getAuthCode()
        self.setNeedsDisplay()
    }
 private   func requistFinished(titles:String) {
        for i in 0..<titles.count {
            codeStrs.append(titles[i])
        }
        self.setNeedsDisplay()
    }
    private   var RandomFont:UIFont {
        return   UIFont.systemFont(ofSize: CGFloat(arc4random()%5 + 13))
    }
    var randomTextColor:UIColor {
        return UIColor.init(red: CGFloat(CFloat(arc4random() % 255) / 255.0), green: CGFloat(CFloat(arc4random() % 255) / 255), blue: CGFloat(CFloat(arc4random() % 255) / 255), alpha: 1)
    }
    var RandomStr:String{
        return titles[(Int(arc4random())%titles.count)]
    }
    lazy var titles :[String] = {
        // A-Z
        var attrs = [String]()
        attrs = []
        for i in 65...90 {
            let bytes:[Int] = [i]
            let data = NSData(bytes: bytes, length: bytes.count)
            let temp:String = String(data: data as Data, encoding: .utf8)!
            attrs.append(temp)
        }
        //        //a-z
        for i in 97...122 {
            let bytes:[Int] = [i]
            let data = NSData(bytes: bytes, length: bytes.count)
            let temp:String = String(data: data as Data, encoding: .utf8)!
            attrs.append(temp)
        }
        //        //0-9
        for i in 48...57 {
            let bytes:[Int] = [i]
            let data = NSData(bytes: bytes, length: bytes.count)
            let temp:String = String(data: data as Data, encoding: .utf8)!
            attrs.append(temp)
        }
        return attrs
    }()
    var isFromeNet:Bool  = false
    
    init(isFromeNet:Bool, frame:CGRect = .zero,codeNum:Int = 4) {
        super.init(frame: frame)
        self.codeNum = codeNum
        self.isFromeNet = isFromeNet
        if  isFromeNet == false{
            getAuthCode()
        }else{
            
        }
        
    }
    func getAuthCode()  {
        codeStrs.removeAll()
        for _ in 0..<codeNum{
            codeStrs.append(titles[Int(arc4random()) % titles.count])
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isFromeNet{
            if let block = self.refreshBlock {
                block({[weak self] (titles) in
                    self?.requistFinished(titles: titles)
                })
            }
        }else{
            refresh()
        }
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ rect: CGRect) {
        let fontSize =  "a".size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)])
        let width:CGFloat = rect.size.width/CGFloat(codeNum) - fontSize.width
        let height:CGFloat = rect.size.height - fontSize.height
        var px:CGFloat = 0
        var py :CGFloat = 0
        for i in 0..<codeNum {
            let char = codeStrs[i] as NSString
            px = CGFloat(arc4random() % UInt32(width))
            px +=  rect.size.width/CGFloat(codeNum) * CGFloat(i)
            py = CGFloat(arc4random() % UInt32(height))
            char.draw(at: CGPoint(x: px, y: py), withAttributes: [NSAttributedString.Key.font :RandomFont,NSAttributedString.Key.foregroundColor:randomTextColor])
        }
        //调用drawRect：之前，系统会向栈中压入一个CGContextRef，调用UIGraphicsGetCurrentContext()会取栈顶的CGContextRef
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(1)
        context?.setStrokeColor(randomTextColor.cgColor)
        context?.setFillColor(randomTextColor.cgColor)
        ////绘制干扰线
        for _ in 0..<klineNum {
            px = CGFloat(arc4random() % UInt32(rect.size.width))
            py = CGFloat(arc4random() % UInt32(rect.size.height))
            context?.move(to: CGPoint(x: px, y: py))
            px = CGFloat(arc4random())/rect.size.width
            py = CGFloat(arc4random())/rect.size.height
            context?.addLine(to: CGPoint(x: px, y: py))
            context?.strokePath()
        }
        
        
    }
}
