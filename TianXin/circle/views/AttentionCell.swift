//
//  AttentionCell.swift
//  TianXin
//
//  Created by pretty on 10/15/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

/// 关注列表cell
class AttentionCell: RxTableViewCell<CircleListCellViewModel> {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var peopleNumButton: UIButton!
    @IBOutlet weak var issueNumButton: UIButton!
    @IBOutlet weak var attentionButton: AttentionButton!
    
    override func bind(_ model: CircleListCellViewModel) {
        super.bind(model)
        
        model.imageUrl.map { try? $0?.asURL() }
            .asDriver(onErrorJustReturn: nil)
            .filterNil()
            .drive(avatarImageView.rx.imageURL)
            .disposed(by: cellDisposeBag)
        model.name.asDriver().drive(nameLabel.rx.text).disposed(by: cellDisposeBag)
        model.userNum.map { "\($0)" }.asDriver(onErrorJustReturn: nil)
            .drive(peopleNumButton.rx.title()).disposed(by: cellDisposeBag)
        model.tzNum.map { "\($0)" }.asDriver(onErrorJustReturn: nil)
            .drive(issueNumButton.rx.title()).disposed(by: cellDisposeBag)
        model.isJoined.asDriver().drive(attentionButton.rx.isAttented).disposed(by: cellDisposeBag)
        
        attentionButton.rx.tap
            .map { model.item }
            .asObservable()
            .bind(to: model.onAttention)
            .disposed(by: cellDisposeBag)
    }
    
    var bgView: UIView? {
        return avatarImageView.superview
    }
}

