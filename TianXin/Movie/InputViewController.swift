//
//  InputViewController.swift
//  TianXin
//
//  Created by pretty on 10/13/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class InputViewController: UIViewController {

    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var textHeightConstraint: NSLayoutConstraint!
    
    static let maxTextHeight = 60 as CGFloat
    static let minTextHeight = 35 as CGFloat
    
    let sendComment = PublishSubject<String>()
    // 喜欢或者取消喜欢视频
    let likeEvent = PublishSubject<Void>()
    // 收藏或者取消收藏视频
    let favoriteEvent = PublishSubject<Void>()
    // 点击评论按钮
    let tapCommentEvent = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.textContainerInset = .init(top: 4, left: 0, bottom: 4, right: 0)
        
        textView.rx.text.map { !($0?.isEmpty ?? true) }.bind(to: placeholderLabel.rx.isHidden).disposed(by: rx.disposeBag)
        textView.rx.text.distinctUntilChanged()
            .flatMapLatest({ [weak self] _ -> Observable<CGFloat> in
                guard let self = self else { return Observable.just(Self.minTextHeight)}
                let size = self.textView.sizeThatFits(.init(width: self.textView.width, height: CGFloat.greatestFiniteMagnitude))
                if size.height > Self.minTextHeight {
                    self.textView.superview?.cornerRadius = 5
                } else {
                    self.textView.superview?.cornerRadius = Self.minTextHeight / 2.0
                }
                return Observable.just(max(Self.minTextHeight, min(size.height, Self.maxTextHeight)))
            })
            .bind(to: textHeightConstraint.rx.constant)
            .disposed(by: rx.disposeBag)
        // 发送评论
//        textView.rx.didEndEditing.asObservable()
//            .subscribe(onNext: {[weak self] in
//                if let text = self?.textView.text, !text.isEmpty {
//                    self?.textView.text = ""
//                    self?.sendComment.onNext(text)
//                }
//            })
//            .disposed(by: rx.disposeBag)
        // 点赞电影
        likeButton.rx.tap
            .bind(to: likeEvent)
            .disposed(by: rx.disposeBag)
        // 收藏电影
        favoriteButton.rx.tap
            .bind(to: favoriteEvent)
            .disposed(by: rx.disposeBag)
        // 分享
        shareButton.rx.tap
            .asObservable()
            .subscribe(onNext: { [weak self] in
                let vc = TuiguangVC()
                vc.isFromeStorybord = true
                self?.show(vc, sender: self)
            })
            .disposed(by: rx.disposeBag)
        commentButton.rx.tap
            .asObservable()
            .subscribe(onNext: {[weak self] in
                if let text = self?.textView.text, !text.isEmpty {
                    self?.textView.text = ""
                    self?.sendComment.onNext(text)
                }
            })
            .disposed(by: rx.disposeBag)
            
    }
    
    func bind(_ isLike: Driver<Bool>, _ isFavorited: Driver<Bool>) {
        isLike.drive(likeButton.rx.isSelected).disposed(by: rx.disposeBag)
        // 取消高亮效果带来的视觉问题
        isLike.map { $0 ? R.image.icon_shoucang() : R.image.icon_dianzan1() }
            .asObservable().bind(to: likeButton.rx.image(for: .normal), likeButton.rx.image(for: .highlighted))
            .disposed(by: rx.disposeBag)
        
        isFavorited.drive(favoriteButton.rx.isSelected).disposed(by: rx.disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textView.resignFirstResponder()
    }
}


