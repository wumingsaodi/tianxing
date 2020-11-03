//
//  PhotoAnimator.swift
//  TianXin
//
//  Created by pretty on 10/27/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class PhotoAnimator {
    var originImage: UIImage?
    var originFrame: CGRect = .zero
    var fromView: UIView?
    
    fileprivate lazy var backgroundView: UIView = {
        guard let window = UIApplication.shared.keyWindow else { fatalError() }
        let backgroundView = UIView(frame: window.frame)
        backgroundView.backgroundColor = UIColor(hex: 0x20242F)
        backgroundView.alpha = 0
        window.addSubview(backgroundView)
        return backgroundView
    }()
    
    fileprivate var presentImageView: UIImageView?
    
    func willPresent(_ browser: PhotoBrowser) {
        presentImageView = UIImageView()
        backgroundView.addSubview(presentImageView!)
        presentImageView?.image = originImage
        
        guard let fromView = self.fromView else { return }
        let startRect = fromView.superview?.convert(fromView.frame, to: nil) ?? .zero
        let endRect = calculateEndRect(originImage)
        presentImageView?.frame = startRect
        
        browser.view.alpha = 0
        browser.view.isHidden = true
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveLinear) {
            self.backgroundView.alpha = 1
            self.presentImageView?.frame = endRect
        } completion: { _ in
            browser.view.alpha = 1
            browser.view.isHidden = false
            self.backgroundView.isHidden = true
            self.presentImageView?.alpha = 0
        }

    }
    
    func willDismiss(_ browser: PhotoBrowser) {
        guard let fromView = self.fromView else {
            browser.dismiss(animated: true) {
                self.presentImageView?.removeFromSuperview()
                self.backgroundView.removeFromSuperview()
            }
            return
        }
        // 获取当前所在的`cell`
        var startRect: CGRect = .zero
        if let listView = findListView() as? UICollectionView,
           let cell = listView.cellForItem(at: IndexPath(row: browser.currentIndex, section: 0)) {
            startRect = listView.convert(cell.frame, to: nil)
        } else {
            startRect = fromView.superview?.convert(fromView.frame, to: nil) ?? .zero
        }
        presentImageView?.image = browser.currentImageView?.image
        presentImageView?.frame = calculateEndRect(presentImageView?.image)
        
        backgroundView.alpha = 1
        presentImageView?.alpha = 1
        backgroundView.isHidden = false
        browser.view.isHidden = true
        
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveLinear) {
            self.backgroundView.alpha = 0
            self.presentImageView?.frame = startRect
        } completion: { _ in
            browser.dismiss(animated: true) {
                self.presentImageView?.removeFromSuperview()
                self.backgroundView.removeFromSuperview()
            }
        }
    }
}

extension PhotoAnimator {
    fileprivate func calculateEndRect(_ image: UIImage?) -> CGRect {
        guard let image = image else { return .zero }
        let imgSize = image.size
        let ratio = imgSize.width / imgSize.height
        let width = /*min(1, imgSize.width / backgroundView.width) * */backgroundView.width - 20
        let height = width / ratio
        let y = (backgroundView.height - height) / 2.0
        let x = 10 as CGFloat
        return .init(x: x, y: y, width: width, height: height)
    }
    
    fileprivate func findListView() -> UIScrollView? {
        var next = fromView?.superview
        while next != nil {
            if next is UIScrollView {
                return next as? UIScrollView
            }
            next = next?.superview
        }
        return nil
    }
}
