//
//  AvatarSelectionCell.swift
//  TianXin
//
//  Created by pretty on 10/15/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class AvatarSelectionCell: UICollectionViewCell {
    @IBOutlet weak var selectionButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func bind(_ model: AvatarSelectionCellViewModel) {
        model.avatarUrl.map { try? $0?.asURL() }.asDriver(onErrorJustReturn: nil)
            .filterNil()
            .drive(avatarImageView.rx.imageURL).disposed(by: rx.disposeBag)
        model.name.asDriver().drive(titleLabel.rx.text).disposed(by: rx.disposeBag)
        model.isSelected.asDriver().drive(selectionButton.rx.isSelected).disposed(by: rx.disposeBag)
    }
}
