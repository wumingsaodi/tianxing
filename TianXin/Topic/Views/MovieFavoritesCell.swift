//
//  MovieFavoritesCell.swift
//  TianXin
//
//  Created by pretty on 10/9/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class MovieFavoritesCell: RxTableViewCell<MovieFavoritesCellViewModel> {
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var updateTimeLabel: UILabel!
    @IBOutlet weak var playCountLabel: UILabel!
    @IBOutlet weak var selecteButton: UIButton!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    
    override func bind(_ model: MovieFavoritesCellViewModel) {
        super.bind(model)
        
        model.cover.map { try? $0?.asURL() }.asDriver(onErrorJustReturn: nil).filterNil()
            .drive(coverImageView.rx.imageURL).disposed(by: cellDisposeBag)
        model.title.asDriver().drive(titleLabel.rx.text).disposed(by: cellDisposeBag)
        model.visitCount.map { $0.unitCountString + "次播放" }.asDriver(onErrorJustReturn: "0次播放")
            .drive(playCountLabel.rx.text).disposed(by: cellDisposeBag)
        
        model.isEditing.map { $0 ? 16 : -23 }.asDriver(onErrorJustReturn: -23)
            .drive(leftConstraint.rx.animationConstant).disposed(by: cellDisposeBag)
        model.isSelected.asDriver().drive(selecteButton.rx.isSelected).disposed(by: cellDisposeBag)
        model.isSelected.bind(to: selecteButton.rx.isSelected).disposed(by: cellDisposeBag)
        // event
        selecteButton.rx.tap.asDriver().drive(onNext: {
            model.isSelected.accept(!model.isSelected.value)
        }).disposed(by: cellDisposeBag)
    }
}
