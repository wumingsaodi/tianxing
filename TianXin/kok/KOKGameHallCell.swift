//
//  KOKGameHallCell.swift
//  TianXin
//
//  Created by pretty on 10/22/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class KOKGameHallCell: UITableViewCell {
    @IBOutlet weak var bgView: UIImageView!
    
    func bind(_ icon: String) {
        bgView.image = UIImage(named: icon)
    }
    
}
