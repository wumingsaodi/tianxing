//
//  MineTaskCell.swift
//  TianXin
//
//  Created by SDS on 2020/10/10.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class MineTaskCell: UITableViewCell {
    let blackTitleColor:UIColor = .Hex("484848")
    let drakblackTitleColor:UIColor =  .Hex("#4E4E4E")
    let detailGrayColor:UIColor = .Hex("#AEAAA8")
    let defualtTitleFont:UIFont =  .pingfangSC(16)
    let smallTitleFont:UIFont  = .pingfangSC(14)
    @IBOutlet weak var doneBut: UIButton!
    @IBOutlet weak var detailLab: UILabel!
    @IBOutlet weak var kokImgv: UIImageView!
    @IBOutlet weak var addCoinLab: UILabel!
    @IBOutlet weak var iconV: UIImageView!
    @IBOutlet weak var titleLab: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
//        doneBut.setBackgroundImage(UIImage.createImgWithColor(color: .Hex("#FFF95E46")), for: .normal)
//        doneBut.setBackgroundImage(UIImage.createImgWithColor(color: .Hex("#FFCBCACF")), for: .selected)//#FFCBCACF
//        doneBut.setTitle("已完成", for: .selected)
    }
    func setModel(model:TaskDdetailModel,isdoneButHide:Bool = false){
        iconV.loadUrl(urlStr: model.task_icon, placeholder: "")
        titleLab.text = model.task_title
        detailLab.text = model.task_content
        doneBut.backgroundColor = .Hex("#FFF95E46")
        if model.task_title.contains("充值") || model.task_title.contains("首充") {
            doneBut.setTitle("去充", for: .normal)
        } else  if model.task_title.contains("推广") {
            doneBut.setTitle("去推", for: .normal)
        }else{
            doneBut.setTitle("去充", for: .normal)
        }
        doneBut.isSelected = model.is_finsh
        if doneBut.isSelected {
            doneBut.backgroundColor =  .Hex("#CBCACF")//#FFCBCACF
            doneBut.setTitle("已完成", for: .normal)
        }
        doneBut.isEnabled = !model.is_finsh
        doneBut.isHidden = isdoneButHide
        if model.task_content.count > 0 {
            addCoinLab.isHidden = true
            kokImgv.isHidden = true
        }else{
            addCoinLab.isHidden = false
            kokImgv.isHidden = false
            addCoinLab.text = "+\(model.task_reward)"
        }
       
        
    }
    
    @IBAction func doneButClick(_ sender: UIButton) {
        if sender.currentTitle == "去充" {
            let vc = RechargeVC()
            if let parent =   self.getViewController(){
                parent.navigationController?.pushViewController(vc, animated: true)
            }
        }else if sender.currentTitle == "去推"{
            let vc = TuiguangVC()
            if let parent =   self.getViewController(){
                parent.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
}
