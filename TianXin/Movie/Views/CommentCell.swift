//
//  CommentCell.swift
//  TianXin
//
//  Created by pretty on 10/12/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CommentCell: UITableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    var cellDisposeBag: DisposeBag!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func bind(_ model: CommentViewModel, likeEvent: Observable<Void>? = nil) {
        cellDisposeBag = DisposeBag()
        
        model.avatar.map { try? $0?.asURL() }.asDriver(onErrorJustReturn: nil)
            .filterNil().drive(avatarImageView.rx.imageURL).disposed(by: cellDisposeBag)
        model.username.asDriver().drive(usernameLabel.rx.text).disposed(by: cellDisposeBag)
        model.time.asDriver().drive(timeLabel.rx.text).disposed(by: cellDisposeBag)
        model.content.asDriver().drive(contentLabel.rx.text).disposed(by: cellDisposeBag)
        model.likeCount.map { "\($0)" }.asDriver(onErrorJustReturn: nil)
            .drive(likeButton.rx.title()).disposed(by: cellDisposeBag)
        model.replyCount.map { "\($0)" }.asDriver(onErrorJustReturn: nil)
            .drive(commentButton.rx.title()).disposed(by: cellDisposeBag)
        model.isLike.asDriver().drive(likeButton.rx.isSelected).disposed(by: cellDisposeBag)
        
        likeButton.rx.tap.map { _ in (model.comment.remarkId, false) }.bind(to: model.onLike)
            .disposed(by: cellDisposeBag)
    }
    
    func bind(_ model: CommentReplyViewModel, likeEvent: Observable<Void>? = nil) {
        cellDisposeBag = DisposeBag()
        
        model.avatar.map { try? $0?.asURL() }.asDriver(onErrorJustReturn: nil)
            .filterNil().drive(avatarImageView.rx.imageURL).disposed(by: cellDisposeBag)
        model.username.asDriver().drive(usernameLabel.rx.text).disposed(by: cellDisposeBag)
        model.time.asDriver().drive(timeLabel.rx.text).disposed(by: cellDisposeBag)
        model.content.asDriver().drive(contentLabel.rx.text).disposed(by: cellDisposeBag)
        model.likeCount.map { "\($0)" }.asDriver(onErrorJustReturn: nil)
            .drive(likeButton.rx.title()).disposed(by: cellDisposeBag)
        model.replyCount.map { "\($0)" }.asDriver(onErrorJustReturn: nil)
            .drive(commentButton.rx.title()).disposed(by: cellDisposeBag)
        
        likeButton.rx.tap.map { _ in (model.reply.replyId, false) }.bind(to: model.onLike)
            .disposed(by: cellDisposeBag)
    }
    
}
