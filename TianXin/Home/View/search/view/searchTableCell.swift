//
//  searchTableCell.swift
//  TianXin
//
//  Created by SDS on 2020/9/22.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class searchTableCell: UITableViewCell {
//    var model:searchVideoModel
    @IBOutlet weak var picV: UIImageView!
    @IBOutlet weak var keyWordLab1: SDSPaddingLabal!
    @IBOutlet weak var keyWordLab2: SDSPaddingLabal!
    @IBOutlet weak var keyWordLab3: SDSPaddingLabal!
    
    @IBOutlet weak var NameL: SDSPaddingLabal!
    @IBOutlet weak var guanKanL: UILabel!
    var keywordLabs:[SDSPaddingLabal] = [SDSPaddingLabal]()
    override func awakeFromNib() {
        super.awakeFromNib()
        keywordLabs.append(keyWordLab1)
        keywordLabs.append(keyWordLab2)
        keywordLabs.append(keyWordLab3)
        // Initialization code
    }
    func setModel(model:searchVideoModel) {
        picV.loadUrl(urlStr: model.pic, placeholder: #imageLiteral(resourceName: "defualt"))
        NameL.text = model.name
        for i in 0..<keywordLabs.count {
            if i >= model.keywords.count{
                keywordLabs[i].isHidden = true
            }else{
                keywordLabs[i].isHidden = false
                keywordLabs[i].text = model.keywords[i]
            }
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
