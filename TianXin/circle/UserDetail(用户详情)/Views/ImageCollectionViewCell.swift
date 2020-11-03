//
//  ImageCollectionViewCell.swift
//  TianXin
//
//  Created by pretty on 10/19/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Kingfisher

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    func bind(_ imageUrl: String) {
        let scale = UIScreen.main.scale
        if let imageURL = try? imageUrl.asURL() {
            imageView.kf.setImage(with: imageURL,options: [
                KingfisherOptionsInfoItem.processor(DownsamplingImageProcessor(size: .init(width: 200 * scale, height: 200 * scale)))
            ])
        }
    }
}
