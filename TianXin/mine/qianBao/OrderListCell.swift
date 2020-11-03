//
//  OrderListCell.swift
//  TianXin
//
//  Created by SDS on 2020/10/28.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class OrderListCell: UITableViewCell {

    @IBOutlet weak var typeL: UILabel!
    @IBOutlet weak var moneyL: UILabel!
    @IBOutlet weak var imgv: UIImageView!
    @IBOutlet weak var statusL: UILabel!
    @IBOutlet weak var timeL: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = baseVCBackGroudColor_grayWhite
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setModel(model:OrderModel,isOder:Bool){
        if isOder {
            imgv.image = #imageLiteral(resourceName: "icon_cunkuan")
        }else{
            imgv.image = #imageLiteral(resourceName: "icon_rechange")
        }
        typeL.text = model.type
        moneyL.text = "+\(model.sumamt)"
        timeL.text = model.orderdate
        statusL.text = model.ordernote
        if model.orderstatus == "ord08"  {//充值成功
            statusL.textColor = .Hex("#09D130")
        }else if model.orderstatus == "ord04"  {//待付款
            statusL.textColor = .Hex("#56575D")
        } else if  model.orderstatus == "ord09"  {//已取消
           statusL.textColor = .Hex("#F50000")
        }
    }
}
