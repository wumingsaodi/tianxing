//
//  CircleDetailHead.swift
//  TianXin
//
//  Created by SDS on 2020/10/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class CircleDetailHead: UIView {
    @IBOutlet weak var bgv: UIView!
    @IBOutlet weak var tieziNumL: UILabel!
    @IBOutlet weak var NumL: UILabel!
    @IBOutlet weak var bgimgv: UIImageView!
    @IBOutlet weak var iconv: UIImageView!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var detailL: UILabel!
    
    @IBOutlet weak var addBut: SDSButton!
    
    var toId:String = ""
    var model:TopRecomedModel?
    
    lazy var vm:CircleDetailViewModel = {
        return CircleDetailViewModel()
    }()
    override func awakeFromNib() {
        super.awakeFromNib()
        bgv.cornor(conorType: UIRectCorner.init(arrayLiteral: .topLeft,.topRight), reduis: 8)
        addBut.cornor(conorType: UIRectCorner.init(arrayLiteral: .topLeft,.bottomLeft), reduis: 12)
        addBut.addTarget(self, action: #selector(addButClick), for: .touchUpInside)
        addBut.setImage(UIImage(), for: .selected)
        addBut.setTitle("已加入", for: .selected)
        addBut.setTitleColor(.white, for: .selected)
        //        vm.requistIssueUserInfo(toId: self.toId) {[weak self] (model) in
        //            self?.refreshUI(model: model)
        //        }
    }
    func refreshUI(model:TopRecomedModel) {
        self.model = model
        nameL.text = model.recommendName
        detailL.text = model.recommendDesc
        iconv.loadUrl(urlStr: model.recommendPic, placeholder: #imageLiteral(resourceName: "tab_mine"))
        NumL.text = "\(model.circleAllCount)"
        tieziNumL.text = "\(model.circleIssueCount)"
        addBut.isSelected = model.isJoin
        addBut.isUserInteractionEnabled =  !model.isJoin   //Int(model.isJoin) ?? 0 <= 0
        if addBut.isSelected {
            addBut.backgroundColor = .Hex("#CBCACF")
        }else{
            addBut.backgroundColor = .Hex("#99FFFFFF")
        }
        
    }
    
}

extension CircleDetailHead {
    @objc func addButClick() {
        if !self.addBut.isSelected {
            NetWorkingHelper.normalPost(url: Configs.Network.Square.addMyJoin, params: ["recommendId":self.model?.recommendId ?? 0]) { [weak self](dict) in
                self?.addBut.isSelected = true
                self?.addBut.isUserInteractionEnabled = false
                self?.addBut.backgroundColor = .Hex("#CBCACF")
                if let vc =  self?.getViewController() as? CircleUserDetailVC{
                    vc.vm.infoModel?.isJoin = true
                }
            }
        }
    }
}
