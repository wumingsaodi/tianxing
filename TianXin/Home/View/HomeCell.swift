//
//  HomeCell.swift
//  TianXin
//
//  Created by SDS on 2020/9/21.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class HomeCell: UICollectionViewCell {
    @IBOutlet weak var guanKsnBut: UIButton!
    
    @IBOutlet weak var dizanBut: UIButton!
    @IBOutlet weak var detailL: UILabel!
    @IBOutlet weak var lastatLab: UIButton!
    @IBOutlet weak var bgIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        lastatLab.isHidden = true
    }
    func setModel(model :HomeItemModel){
         let width = (Configs.Dimensions.screenWidth - 20 - scaleX(30))/2
        let height = width / 175  * 125
        bgIcon.loadUrl(urlStr: model.pic, placeholder: "",size:CGSize(width: width, height: height))
        detailL.text = model.name
        let lovetext:String = model.loveNums > 10000 ? String(format: "%0.1f万", Float(model.loveNums) / 10000.0 ) :"\(model.loveNums)"
        let guankText:String = model.historyNum > 10000 ? String(format: "%0.1f万", Float(model.historyNum) / 10000.0 ) :"\(model.historyNum)"
        dizanBut.setTitle(lovetext, for: .normal)
        guanKsnBut.setTitle( guankText, for: .normal)
    }
    @IBAction func dianZanButClick(_ sender: UIButton) {
        
    }
}
