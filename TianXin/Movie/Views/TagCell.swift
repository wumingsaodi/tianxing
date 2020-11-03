//
//  TagCell.swift
//  TianXin
//
//  Created by pretty on 10/12/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class TagCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    
    func bind(text: String) {
        label.text = text
    }
}
