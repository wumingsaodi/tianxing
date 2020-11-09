//
//  VideoCollectionViewCell.swift
//  TianXin
//
//  Created by pretty on 10/21/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class VideoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var playerView: SDSAVView!
    
    func bind(_ videoUrl: String) {
        playerView.isCanBeiginPlay = false
        playerView.url = try? videoUrl.asURL()
    }
}
