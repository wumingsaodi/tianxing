//
//  TopicListCell.swift
//  TianXin
//
//  Created by pretty on 10/7/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional

class TopicListCell: RxTableViewCell<TopicViewCellViewModel> {
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func bind(_ model: TopicViewCellViewModel) {
        super.bind(model)
        
        model.title.asDriver().drive(titleLabel.rx.text).disposed(by: cellDisposeBag)
        model.cover.map{ try? $0?.asURL() }.asDriver(onErrorJustReturn: nil).filterNil()
            .drive(coverImageView.rx.imageURL).disposed(by: cellDisposeBag)
        model.remark.asDriver().drive(subtitleLabel.rx.text).disposed(by: cellDisposeBag)
        model.number.asDriver().drive(countLabel.rx.text).disposed(by: cellDisposeBag)
        
    }
}
