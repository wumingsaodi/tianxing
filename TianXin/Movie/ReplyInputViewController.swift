//
//  ReplyInputViewController.swift
//  TianXin
//
//  Created by pretty on 10/13/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ReplyInputViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textHeightConstraint: NSLayoutConstraint!
    
    static let maxTextHeight = 60 as CGFloat
    static let minTextHeight = 35 as CGFloat
    
    let replyEvent = PublishSubject<String>()
    
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
        sendButton.rx.tap.asObservable()
            .subscribe(onNext: {[weak self] in
                if let text = self?.textView.text, !text.isEmpty {
                    self?.textView.text = ""
                    self?.replyEvent.onNext(text)
                    self?.textView.resignFirstResponder()
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    func bind(_ username: Driver<String>) {
        username.map { "回复\($0)" }.asDriver(onErrorJustReturn: nil)
            .drive(placeholderLabel.rx.text).disposed(by: rx.disposeBag)
    }
    
}
