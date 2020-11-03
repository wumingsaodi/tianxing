//
//  CircleHomeRemarkCell.swift
//  TianXin
//
//  Created by SDS on 2020/10/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class CircleHomeRemarkCell: UITableViewCell {
    var delBlock:(()->Void)?
    var AttentionClickBlock:(( _ isAdd:Bool)->Void)?
    @IBOutlet weak var iconv: UIImageView!
    @IBOutlet weak var titleL: UILabel!
    
    @IBOutlet weak var textL: UILabel!
    @IBOutlet weak var dianZanBut: SDSButton!
    @IBOutlet weak var imageL: UILabel!
    @IBOutlet weak var timeL: UILabel!
    var selfIconUrl:String = ""
    var model:RemarkModel =  RemarkModel()
    override func awakeFromNib() {
        super.awakeFromNib()
        dianZanBut.isEnabled = false
        dianZanBut.isSelected = true
        self.selectionStyle = .none
        
      LocalUserInfo.share.getLoginInfo {[weak self] (model) in
            self?.selfIconUrl = model!.userLogo
        }
    }
       
    @IBAction func delButClick(_ sender: UIButton) {
        if let block = delBlock {
            block()
        }
    }
    @IBAction func dianZanButClick(_ sender: UIButton) {
        if let  block = AttentionClickBlock{
            block(!sender.isSelected)
        }

    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setModel(model:RemarkModel){
        self.model = model
        iconv.loadUrl(urlStr: selfIconUrl, placeholder: #imageLiteral(resourceName: "tab_mine_selected"))
//        iconv.loadUrl(urlStr: model.userLogo, placeholder: #imageLiteral(resourceName: "tab_mine_selected"))
        titleL.text = model.remark
        //
        if model.issuePic.count > 0 {
            imageL.text = "【图片】"
        }else{
            imageL.text = ""
        }
        textL.text = model.issueContent
        //
        timeL.text = model.createTime
        dianZanBut.setTitle("\(model.squareRemarkCount)", for: .normal)
        dianZanBut.isSelected =  Int(model.isAttention) ?? 0 > 0
    }
}
