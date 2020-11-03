//
//  MineTaskHeadersecond.swift
//  TianXin
//
//  Created by SDS on 2020/10/10.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class MineTaskHeadersecond: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLab: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setTitle(title:String) {
        self.titleLab.text = title
    }
    
}
