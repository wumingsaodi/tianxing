//
//  FloatingButton.swift
//  TianXin
//
//  Created by pretty on 10/14/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit


extension FloatingButton {
    static var `default`: FloatingButton {
        return FloatingButton(image: R.image.button_bianji())
    }
}

class FloatingButton: UIView {
    private var position: FloatingPosition = .default {
        willSet {
            updatePosition(position: newValue)
        }
    }
    var tapAction: (() -> Void)?
    lazy private var button: UIButton = {
        let btn = UIButton(type: .custom)
        return btn
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        button.frame = self.bounds
        button.addTarget(self, action: #selector(onTap(sender:)), for: .touchUpInside)
        self.addSubview(button)
    }
    convenience init(title: String? = nil, image: UIImage? = nil) {
        self.init(frame: .init(x: 0, y: 0, width: 50, height: 50))
        button.setImage(image, for: .normal)
        button.setTitle(title, for: .normal)
        // 添加阴影
        self.addShadow()
        // 添加手势
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(sender:)))
        self.addGestureRecognizer(panGesture)
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(in view: UIView? = nil, tapAction: (() -> Void)? = nil) {
        self.tapAction = tapAction
        if let v = view {
            v.addSubview(self)
            position = .default
            return
        }
        // 获取当前的window
        let keyWindow: UIWindow??
        if #available(iOS 13.0, *) {
            keyWindow = UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .map { $0 as? UIWindowScene }
                .compactMap({$0})
                .first?.windows
                .filter { $0.isKeyWindow }
                .first
            
        } else {
            keyWindow = UIApplication.shared.delegate?.window
        }
        guard let rooter = keyWindow??.rootViewController as? UITabBarController,
              let navc = rooter.selectedViewController as? UINavigationController,
              let rootVc = navc.topViewController else {
            return
        }
        rootVc.view.addSubview(self)
    }
    
    private func safeArea() -> UIEdgeInsets {
        guard let sp = superview else { return .zero }
        
        var frameInset: UIEdgeInsets

        var bottomBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height > 20 ? 34 : 0
        if let bottomBarHidden = sp.viewController()?.hidesBottomBarWhenPushed, !bottomBarHidden {
            bottomBarHeight += 49
        }
        if #available(iOS 11.0, *) {
            frameInset = UIApplication.shared.keyWindow?.safeAreaInsets ?? UIEdgeInsets(top: UIApplication.shared.statusBarFrame.height, left: 0, bottom: 0, right: 0)
        } else {
            frameInset = UIDevice.current.orientation.isPortrait ? UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0) : .zero
        }
        return frameInset + .init(top: 44, left: 10, bottom: bottomBarHeight, right: 10)
    }
    
    private func updatePosition(position: FloatingPosition) {
        guard let sp = superview else { return }
        let frameInset = safeArea()
        // 屏幕居中
        if position == .center {
            self.center = sp.center
            return
        }
        if position.contains(.left) {
            self.frame.origin.x = frameInset.left
            self.center.y = sp.center.y
        }
        if position.contains(.right) {
            self.frame.origin.x = sp.width - self.width - frameInset.right
            self.center.y = sp.center.y
        }
        if position.contains(.bottom) {
            self.frame.origin.y = sp.height - self.height - frameInset.bottom
            if self.frame.origin.x == 0 {
                self.center.x = center.x
            }
        }
        if position.contains(.top) {
            self.frame.origin.y = frameInset.top
            if self.frame.origin.x == 0 {
                self.center.x = center.x
            }
        }
    }
    @objc private func onTap(sender: UIButton) {
        if let tapAction = self.tapAction {
            tapAction()
            return
        }
        // 跳转到编辑界面
        let vc = PostingViewController.instanceFrom(storyboard: "Circle")
        let curVc = self.superview?.viewController()
        curVc?.navigationController?.pushViewController(vc, isNeedLogin: true, animated: true)
//        tapAction?()
    }
    
    @objc private func onPan(sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: { [weak self] in
                self?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                }, completion: nil)
        }
        
        let offset = sender.translation(in: self.superview)
        sender.setTranslation(CGPoint.zero, in: self.superview)
        var center = self.center
        center.x += offset.x
        center.y += offset.y
        self.center = center
        
        if sender.state == .ended || sender.state == .cancelled {
            let frameInset = safeArea()
            
            let location = sender.location(in: self.superview)
            let velocity = sender.velocity(in: self.superview)
            
            var finalX: Double = Double(self.width/8*4.25) + Double(frameInset.left)
            var finalY: Double = Double(location.y)
            
            if location.x > UIScreen.main.bounds.size.width / 2 {
                finalX = Double(UIScreen.main.bounds.size.width) - Double(self.width/8*4.25) - Double(frameInset.right)
            }
            
            let horizentalVelocity = abs(velocity.x)
            let positionX = abs(finalX - Double(location.x))
            
            let velocityForce = sqrt(pow(velocity.x, 2) * pow(velocity.y, 2))
            
            let durationAnimation = (velocityForce > 1000.0) ? min(0.3, positionX / Double(horizentalVelocity)) : 0.3
            
            if velocityForce > 1000.0 {
                finalY += Double(velocity.y) * durationAnimation
            }
            
            if finalY > Double(UIScreen.main.bounds.size.height) - Double(self.height/8*4.25) {
                finalY = Double(UIScreen.main.bounds.size.height) - Double(frameInset.bottom) - Double(self.height/8*4.25)
            } else if finalY < Double(self.height/8*4.25) + Double(frameInset.top)  {
                finalY = Double(self.height/8*4.25) + Double(frameInset.top)
            }
            UIView.animate(withDuration: durationAnimation * 5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: .allowUserInteraction, animations: { [weak self] in
                self?.center = CGPoint(x: finalX, y: finalY)
                self?.transform = CGAffineTransform.identity
            }, completion:nil)
        }
    }
    
}

extension FloatingButton {
    struct FloatingPosition: OptionSet {
        let rawValue: Int
        init(rawValue: Int) {
            self.rawValue = rawValue
        }
        static let top = FloatingPosition(rawValue: 1 << 0)
        static let left = FloatingPosition(rawValue: 1 << 1)
        static let bottom = FloatingPosition(rawValue: 1 << 2)
        static let right = FloatingPosition(rawValue: 1 << 3)
        static let center = FloatingPosition(rawValue: 1 << 4)
        // 默认为右下角
        static let `default`: FloatingPosition = [.right, .bottom]
    }
}

extension FloatingButton {
    
}

extension UIEdgeInsets {
    static func + (lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
        return .init(top: lhs.top + rhs.top,
                     left: lhs.left + rhs.left,
                     bottom: lhs.bottom + rhs.bottom,
                     right: lhs.right + rhs.right)
    }
}
