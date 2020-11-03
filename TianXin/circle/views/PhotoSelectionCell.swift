//
//  PhotoSelectionCell.swift
//  TianXin
//
//  Created by pretty on 10/15/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class PhotoSelectionCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    func bind(_ model: PostingViewController.PhotoSelectionCellViewModel) {
        model.image.asDriver().drive(imageView.rx.image).disposed(by: rx.disposeBag)
        deleteButton.isHidden = model.type == .add
        imageView.contentMode = model.type == .add ? .center : .scaleAspectFill
        deleteButton.rx.tap
            .asObservable()
            .map { [weak self] in self?.indexPath?.row }
            .filterNil()
            .bind(to: model.deleted)
            .disposed(by: rx.disposeBag)
    }
}

extension PhotoSelectionCell {
    var indexPath: IndexPath? {
        if let collectionView = self.superview as? UICollectionView {
            return collectionView.indexPath(for: self)
        }
        return nil
    }
}
