//
//  CommentCell2.swift
//  TianXin
//
//  Created by pretty on 10/19/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CommentCell2: RxTableViewCell<IssueCommentReplyItemViewModel> {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.isUserInteractionEnabled = true
    }
    
    override func bind(_ model: IssueCommentReplyItemViewModel) {
        super.bind(model)
        
        model.avatar.map { try? $0?.asURL() }.filterNil()
            .asDriver(onErrorJustReturn: nil)
            .drive(avatarImageView.rx.imageURL)
            .disposed(by: cellDisposeBag)
        model.name.asDriver().drive(nameLabel.rx.text).disposed(by: cellDisposeBag)
        model.time.asDriver().drive(timeLabel.rx.text).disposed(by: cellDisposeBag)
        model.content.asDriver().drive(contentLabel.rx.text).disposed(by: cellDisposeBag)
        model.likeCount.map { "\($0)" }.asDriver(onErrorJustReturn: nil)
            .drive(likeButton.rx.title()).disposed(by: cellDisposeBag)
        model.replyCount.map {"\($0)"}.asDriver(onErrorJustReturn: nil)
            .drive(replyButton.rx.title()).disposed(by: cellDisposeBag)
        model.isLiked.asDriver().drive(likeButton.rx.isSelected).disposed(by: cellDisposeBag)
    
        cellDisposeBag = DisposeBag()
        
        avatarImageView.rx.tapGesture()
            .when(.ended)
            .map{_ in "\(model.issueRemark.userId)" }
            .bind(to: model.tapAvatar)
            .disposed(by: cellDisposeBag)
        likeButton.rx.tap
            .map{[weak self] in ("\(model.issueRemark.remarkId)", !(self?.likeButton.isSelected ?? false))}
            .bind(to: model.onLike)
            .disposed(by: cellDisposeBag)
        replyButton.rx.tap
            .map{_ in "\(model.issueRemark.remarkId)"}
            .bind(to: model.onReply)
            .disposed(by: cellDisposeBag)
        
    }
}
