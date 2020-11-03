//
//  KOKPresentViewController.swift
//  TianXin
//
//  Created by pretty on 10/22/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class KOKPresentViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var backgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomConstraint.constant = -KScreenH * 0.8
//        // 点击 view，消失
        self.backgroundView.rx.tapGesture()
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
        // 点击menu item
        stackView.arrangedSubviews.forEach { [weak self] view in
            guard let button = view as? KOKMenuItem else { return }
            button.rx.tap
                .asObservable()
                .subscribe(onNext: {[weak self] in
                    self?.tapMenu(atIndex: button.tag)
                })
                .disposed(by: rx.disposeBag)
        }
        (stackView.arrangedSubviews.first as? KOKMenuItem)?.isSelected = true
        // scroll
        contentScrollView.rx.didScroll
            .asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let index = Int(round(self.contentScrollView.contentOffset.x / self.contentScrollView.width))
                self.stackView.arrangedSubviews.forEach({($0 as? KOKMenuItem)?.isSelected = false})
                (self.stackView.arrangedSubviews[index] as? KOKMenuItem)?.isSelected = true
            })
            .disposed(by: rx.disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded()
        self.stackView.superview?.roundCorners([.topLeft, .topRight], radius: 8)
        contentScrollView.contentSize = .init(width: contentScrollView.width * 6, height: contentScrollView.height)
        contentScrollView.updateConstraintsIfNeeded()
        
        let types: [GameType] = [.体育, .真人, .电竞, .彩票, .棋牌, .电子]
        if children.count >= 6 {
            return
        }
        types.enumerated().forEach { (index, type) in
            let vc = KOKGameKindViewController.instanceFrom(storyboard: "Kok")
            vc.viewModel = KOKGameKindViewControllerModel(type: type)
            addChild(vc)
            vc.view.frame = .init(x: contentScrollView.width * CGFloat(index), y: 0, width: contentScrollView.width, height: contentScrollView.height)
            contentScrollView.addSubview(vc.view)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presentAnimation()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissAnimation()
    }
}

extension UIViewController {
    func presentKOK() {
        let vc = KOKPresentViewController.instanceFrom(storyboard: "Kok")
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.showDetailViewController(vc, sender: self)
    }
}

extension KOKPresentViewController {
    fileprivate func tapMenu(atIndex index: Int) {
        contentScrollView.scrollRectToVisible(.init(x: contentScrollView.width * CGFloat(index), y: 0, width: contentScrollView.width, height: contentScrollView.height), animated: true)
    }
    fileprivate func presentAnimation() {
        bottomConstraint.constant = 0
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func dismissAnimation() {
        bottomConstraint.constant = -KScreenH * 0.8
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}
