//
//  TopicMovieListCell.swift
//  TianXin
//
//  Created by pretty on 10/8/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class TopicMovieListCell: RxCollectionViewCell<TopicMovieListCellViewModel> {
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var lookButton: UIButton!
    
    override func bind(_ model: TopicMovieListCellViewModel) {
        super.bind(model)
        
        model.title.asDriver().drive(titleLabel.rx.text).disposed(by: cellDisposeBag)
        model.cover.map { try? $0?.asURL() }.asDriver(onErrorJustReturn: nil).filterNil()
            .drive(coverImageView.rx.imageURL).disposed(by: cellDisposeBag)
        model.videoLikeCount.map { "\($0)" }.asDriver(onErrorJustReturn: "0")
            .drive(likeButton.rx.title(for: .normal)).disposed(by: cellDisposeBag)
        model.visitCount.map { "\($0)" }.asDriver(onErrorJustReturn: "0")
            .drive(lookButton.rx.title(for: .normal)).disposed(by: cellDisposeBag)
        model.isLike.asDriver().drive(likeButton.rx.isSelected).disposed(by: cellDisposeBag)
    }
}
