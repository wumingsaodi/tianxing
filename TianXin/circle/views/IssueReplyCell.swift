//
//  IssueReplyCell.swift
//  TianXin
//
//  Created by pretty on 10/20/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class IssueReplyCell: CommentCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.isUserInteractionEnabled = true
    }
    
    func bind(_ model: IssueReplyItemViewModel) {
        cellDisposeBag = DisposeBag()
        model.avatar.map{try? $0?.asURL() }.asDriver(onErrorJustReturn: nil)
            .drive(avatarImageView.rx.imageURL).disposed(by: cellDisposeBag)
        model.name.asDriver().drive(usernameLabel.rx.text).disposed(by: cellDisposeBag)
        model.time.asDriver().drive(timeLabel.rx.text).disposed(by: cellDisposeBag)
//        model.content.asDriver().drive(contentLabel.rx.text).disposed(by: cellDisposeBag)
        model.content.asDriver().drive(contentLabel.rx.attributedText).disposed(by: cellDisposeBag)
        model.likeNum.map{"\($0)"}.asDriver(onErrorJustReturn: "0")
            .drive(likeButton.rx.title()).disposed(by: cellDisposeBag)
        model.replyNum.map{"\($0)"}.asDriver(onErrorJustReturn: "0")
            .drive(commentButton.rx.title()).disposed(by: cellDisposeBag)
        
        avatarImageView.rx.tapGesture()
            .when(.ended)
            .asObservable()
            .map{_ in "\(model.issueReply.userId ?? 0)"}
            .bind(to: model.tapAvatar)
            .disposed(by: cellDisposeBag)
        likeButton.rx.tap
            .map({[weak self] in ("\(model.issueReply.replyId ?? 0)", !(self?.likeButton.isSelected ?? false))})
            .bind(to: model.onLike)
            .disposed(by: cellDisposeBag)
    }
    
}
