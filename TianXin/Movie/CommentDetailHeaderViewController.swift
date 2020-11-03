//
//  CommentDetailHeaderViewController.swift
//  TianXin
//
//  Created by pretty on 10/13/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CommentDetailHeaderViewController: UIViewController {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var attentionLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    let tap = PublishSubject<Comment>()
    
    func bind(_ model: CommentViewModel, isAttention: Driver<Bool>, likeCount: Driver<Int>) {
        model.avatar.map { try? $0?.asURL() }.asDriver(onErrorJustReturn: nil)
            .drive(avatarImageView.rx.imageURL).disposed(by: rx.disposeBag)
        model.username.asDriver().drive(nameLabel.rx.text).disposed(by: rx.disposeBag)
        model.content.asDriver().drive(contentLabel.rx.text).disposed(by: rx.disposeBag)
        model.time.asDriver().drive(timeLabel.rx.text).disposed(by: rx.disposeBag)
        // 计算高度
        model.content.asObservable()
            .filterNil()
            .map { [weak self] text -> CGFloat in
                guard let self = self else { return 0 }
                let width = self.contentLabel.width
                let font = self.contentLabel.font
                return (text as NSString).boundingRect(with: .init(width: width, height: CGFloat.greatestFiniteMagnitude),
                                                options: .usesFontLeading,
                                                attributes: [.font: font!],
                                                context: nil).size.height
            }.observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] height in
                self?.view.height = height + 132
            })
            .disposed(by: rx.disposeBag)
        isAttention.map { $0 ?  "已关注": "关注" }.asDriver()
            .drive(attentionLabel.rx.text).disposed(by: rx.disposeBag)
        isAttention.map { $0 ? UIColor(white: 0.61, alpha: 1): Configs.Theme.Color.primary}.asDriver()
            .drive(onNext: { [weak self]color in
                self?.attentionLabel.superview?.borderColor = color
                self?.attentionLabel.textColor = color
            }).disposed(by: rx.disposeBag)
        likeCount.map { "\($0)" }.asDriver().drive(likeButton.rx.title()).disposed(by: rx.disposeBag)
        
        self.view.rx.tapGesture()
            .when(.ended)
            .map {  _ in return model.comment }
            .asObservable().bind(to: tap).disposed(by: rx.disposeBag)
            
    }

}

extension Reactive where Base: UIView {
    var solidColor: Binder<UIColor?> {
        return Binder<UIColor?>(self.base) {
            view, color in
            view.borderColor = color
        }
    }
}
