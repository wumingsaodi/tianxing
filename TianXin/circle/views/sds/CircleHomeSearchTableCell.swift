//
//  CircleHomeSearchTableCell.swift
//  TianXin
//
//  Created by SDS on 2020/10/31.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CircleHomeSearchTableCell: UITableViewCell {
    
    @IBOutlet weak var detailL: UILabel!
    @IBOutlet weak var iconv: UIImageView!
    
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var guanzhu: SDSButton!
    @IBOutlet weak var dianZanBut: SDSButton!
    @IBOutlet weak var remarkBut: SDSButton!
    @IBOutlet weak var timeL: UILabel!
    var AddOrNoAddSubJet = PublishSubject<CircleHomeModel>()
    var model:CircleHomeModel? {
        didSet{
            guard let model = model else{
                return
            }
            iconv.loadUrl(urlStr: model.userLogo, placeholder: #imageLiteral(resourceName: "defult_user"))
            dianZanBut.setTitle("\(model.issueLikeCount)", for: .normal)
            remarkBut.setTitle("\(model.squareRemarkCount)", for: .normal)
            dianZanBut.isSelected = model.isIssueLike
        
            timeL.text = model.createTime
            guanzhuBut(slected: model.isAttention)
//            guanzhu.isSelected = model.isAttention
            detailL.text = model.issueContent
            nameL.text = model.nickName.count > 0 ? model.nickName : model.userName
            //                NetWorkingHelper.normalPost(url: Configs.Network.Square.addAttention, params: ["toId":self!.models[indexPath.row].userId]) { [weak self](dict) in
//            self?.models[indexPath.row].isAttention = true
//            
//            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
//        }

        }
    }
    func guanzhuBut(slected:Bool){
        let guanZhuBut = guanzhu!
        if slected {
            guanZhuBut.setImage(UIImage(), for: .normal)
            guanZhuBut.setTitle("已关注", for: .normal)
            guanZhuBut.cornor(conorType: .allCorners, reduis: guanZhuBut.sdsH*0.5, borderWith: 1, borderColor: .clear)
//            guanZhuBut.isEnabled = false
            guanZhuBut.backgroundColor = .Hex("#FFF3F3F3")
            guanZhuBut.setTitleColor(.Hex("#b2b2b4"), for: .normal)
        }else{
             guanZhuBut.setTitle("关注", for: .normal)
//            guanZhuBut.setButType(type: .imgLeft, padding: 10)
            guanZhuBut.setImage(#imageLiteral(resourceName: "icon_guanzhu"), for: .normal)
            guanZhuBut.cornor(conorType: .allCorners, reduis: guanZhuBut.sdsH * 0.5, borderWith: 1, borderColor: mainYellowColor)
//                guanZhuBut.isEnabled = true
                guanZhuBut.backgroundColor = .clear
                guanZhuBut.setTitleColor(mainYellowColor, for: .normal)
           
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        remarkBut.isUserInteractionEnabled = false
        dianZanBut.isUserInteractionEnabled = false
        guanzhu.rx.tap.subscribe(onNext: { [weak self] in
            let isAdd = !(self?.model?.isAttention ?? true)
            if isAdd {//关注
                NetWorkingHelper.normalPost(url: Configs.Network.Square.addAttention, params: ["toId":self!.model!.userId]) { [weak self](dict) in
                    self?.model?.isAttention = true
                    self?.AddOrNoAddSubJet.onNext((self?.model)!)
                }
            }else{//取消关注
                NetWorkingHelper.normalPost(url: Configs.Network.Square.delMyAttention, params: ["toId":self!.model!.userId]) { [weak self](dict) in
                
                    self?.model?.isAttention = false
                    self?.AddOrNoAddSubJet.onNext((self?.model)!)
                }
            }
        
            
        }).disposed(by: rx.disposeBag)
//        guanzhu.isUserInteractionEnabled = false
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
