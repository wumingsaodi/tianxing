//
//  UserDetailHeaderViewController.swift
//  TianXin
//
//  Created by pretty on 10/16/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UserDetailHeaderViewController: UIViewController {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var navBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var navBarBackgroundView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var attentionButton: AttentionButton!
    
    @IBOutlet weak var fansNumLabel: UILabel!
    @IBOutlet weak var attentionNumLabel: UILabel!
    @IBOutlet weak var circleNumLabel: UILabel!
    
    @IBOutlet weak var avatarLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var joinButtonRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    lazy private var navBarHeight = 44 as CGFloat
    lazy private var barHeight = navBarHeight + UIApplication.shared.statusBarFrame.height
    private let animSpeed = 100 as CGFloat
    
    let toper = PublishSubject<CGFloat>()
    let attentionEvent = PublishSubject<Bool>()
    
    var model: Driver<JSON>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navBarBackgroundView.addShadow()
        navBarHeightConstraint.constant = navBarHeight + UIApplication.shared.statusBarFrame.height
        trackAnimation()
        
        circleNumLabel.superview?.rx.tapGesture()
            .compactMap({[weak self] _ in self?.model?.asObservable()})
            .flatMapLatest({ $0 })
            .subscribe(onNext: { [weak self] model in
                let vc = CircleListViewController.instanceFrom(storyboard: "Circle")
                vc.viewModel = CircleListViewControllerModel(userId: model.id.string)
                self?.show(vc, sender: self)
            })
            .disposed(by: rx.disposeBag)
        fansNumLabel.superview?.rx.tapGesture()
            .compactMap({[weak self] _ in self?.model?.asObservable()})
            .flatMapLatest({$0})
            .subscribe(onNext: { [weak self] model in
                let vc = FansListViewController.instanceFrom(storyboard: "UserDetail")
                vc.viewModel = FansListViewControllerModel(model.id.string)
                self?.show(vc, sender: self)
            })
            .disposed(by: rx.disposeBag)
        attentionNumLabel.superview?.rx.tapGesture()
            .compactMap({[weak self] _ in self?.model?.asObservable()})
            .flatMapLatest({$0})
            .subscribe(onNext: { [weak self] model in
                let vc = FansListViewController.instanceFrom(storyboard: "UserDetail")
                vc.viewModel = FansListViewControllerModel(model.id.string, direction: .to)
                self?.show(vc, sender: self)
            })
            .disposed(by: rx.disposeBag)

    }
    
    func trackAnimation() {
        toper.asObservable().bind(to: navBarTopConstraint.rx.constant).disposed(by: rx.disposeBag)
        toper.asObservable()
            .map { [weak self] top in
                guard let self = self else { return UIColor.clear }
                if top < 15 { return UIColor.clear }
                let alpha = min(1, (top - 15) / (self.view.height - 15 - self.barHeight) * 3)
                return UIColor(white: 1, alpha: alpha)
            }
            .bind(to: navBarBackgroundView.rx.backgroundColor)
            .disposed(by: rx.disposeBag)
        
        toper.asObservable()
            .subscribe(onNext: { [weak self ]top in
                guard let self = self else { return }
                let progress: CGFloat
                if top < 15 {
                    progress = 0
                } else {
                    progress = min(1, (top - 15) / self.animSpeed)
                }
                let endAvatarSize = 30 as CGFloat
                let startAvatarSize = 71 as CGFloat
                let endAvatarLeft = 45 as CGFloat
                let startAvatarLeft = 15 as CGFloat
                let startAvatarTop = 15 as CGFloat
                let endAvatarTop = -(self.navBarHeight + endAvatarSize) / 2.0
                
                self.nameLabel.textColor = .init(white: 1 - progress, alpha: 1)
                self.avatarLeftConstraint.constant = startAvatarLeft + (endAvatarLeft - startAvatarLeft) * progress
                self.avatarWidthConstraint.constant = startAvatarSize + (endAvatarSize - startAvatarSize) * progress
                self.avatarHeightConstraint.constant = startAvatarSize + (endAvatarSize - startAvatarSize) * progress
                self.avatarImageView.cornerRadius =  self.avatarHeightConstraint.constant / 2.0
                self.avatarTopConstraint.constant = startAvatarTop + (endAvatarTop - startAvatarTop) * progress
                self.joinButtonRightConstraint.constant = 15 * progress
            })
            .disposed(by: rx.disposeBag)
    }
    
    func bind(_ model: Driver<JSON>, isAttention: Driver<Bool>) {
        self.model = model
        
        model.map { try? $0.userLogo.string.asURL() }
            .filterNil()
            .drive(avatarImageView.rx.imageURL)
            .disposed(by: rx.disposeBag)
        model.map { $0.nickName.string.isEmpty ? $0.userName.string : $0.nickName.string }
            .drive(nameLabel.rx.text).disposed(by: rx.disposeBag)
        model.map { "\($0.recommendCount.int)" }.drive(circleNumLabel.rx.text).disposed(by: rx.disposeBag)
        model.map { "\($0.careCount.int)" }.drive(attentionNumLabel.rx.text).disposed(by: rx.disposeBag)
        model.map { "\($0.beCaredCount.int)" }.drive(fansNumLabel.rx.text).disposed(by: rx.disposeBag)
        isAttention.drive(attentionButton.rx.isAttented).disposed(by: rx.disposeBag)
        model.map { try? $0.userBackgroundPic.string.asURL() }
            .filterNil()
            .drive(backgroundImageView.rx.imageURL)
            .disposed(by: rx.disposeBag)
        
        attentionButton.rx.tap
            .map{[weak self] _ in !(self?.attentionButton.isAttented ?? false)}
            .bind(to: attentionEvent)
            .disposed(by: rx.disposeBag)
        // 如果是自己主页，则不显示关注按钮
        model.map { $0.id.int == LocalUserInfo.share.userId }.drive(attentionButton.rx.isHidden).disposed(by: rx.disposeBag)
    }
    
    
    @IBAction func onBack(_ sender: UIButton) {
        self.goBack(sender)
    }
    
}
