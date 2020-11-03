//
//  DebugUI.swift
//  TianXin
//
//  Created by pretty on 11/2/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

#if DEBUG
import RxSwift

class UIDebug {
    static let shared = UIDebug()
    lazy private var window = UIDebugWindow(frame: UIScreen.main.bounds)
    lazy private var label: UILabel = {
        let label = UILabel(frame: .init(x: 0, y: UIApplication.shared.statusBarFrame.height, width: Configs.Dimensions.screenWidth, height: 20))
        label.backgroundColor = .init(white: 0, alpha: 0.7)
        label.textColor = .green
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    private let diposeBag = DisposeBag()
    func enable() {
        if !window.subviews.isEmpty { return }
        window.addSubview(label)
        window.bounds.size.height = UIScreen.main.bounds.height.nextDown

        if let mainVC = UIApplication.shared.windows.first?.rootViewController as? UITabBarController {
            if let navc = mainVC.selectedViewController as? UINavigationController, let vc =  navc.topViewController {
                self.label.text = "当前控制器：\(type(of: vc))"
            } else if let vc = mainVC.selectedViewController {
                self.label.text = "当前控制器：\(type(of: vc))"
            }
            let children = mainVC.viewControllers?.filter({$0 is UINavigationController}) as? [UINavigationController]
            children?.forEach({
                $0.rx.willShow.asObservable()
                    .subscribe(onNext: { [weak self] (vc, animated) in
                        guard let self = self else { return }
                        self.label.text = "当前控制器：\(type(of: vc))"
                    })
                    .disposed(by: self.diposeBag)
            })
        }
        if #available(iOS 13.0, *) {
            var success: Bool = false
            
            for i in 0...10 {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + (0.1 * Double(i))) {[weak self] in
                    if success == true {return}
                    
                    for scene in UIApplication.shared.connectedScenes {
                        if let windowScene = scene as? UIWindowScene {
                            self?.window.windowScene = windowScene
                            success = true
                        }
                    }
                }
            }
        }
    }
    
}
class UIDebugWindow: UIWindow {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isHidden = false
        self.windowLevel = UIWindow.Level(rawValue: UIWindow.Level.alert.rawValue - 1)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
}
#endif
