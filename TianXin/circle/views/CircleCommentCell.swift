//
//  CircleCommentCell.swift
//  TianXin
//
//  Created by SDS on 2020/10/5.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class CircleCommentCell: UITableViewCell {
    typealias OnTapAvatar = (_ model: RemarkModel) -> Void
    var tapAvatar: OnTapAvatar?
    var model:RemarkModel = RemarkModel()
    var UserLoveBlock:((_ isLike:Bool,_ type:String,_ remarkId:String?)->Void)?
   static let cellH :CGFloat = 92
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUI() {
        self.contentView.backgroundColor  = baseVCBackGroudColor_grayWhite
        self.contentView.addSubview(iconv)
        iconv.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(11)
            make.top.equalToSuperview().offset(20)
            make.size.equalTo(CGSize(width: 43.5, height: 43.5))
        }
        self.contentView.addSubview(nameL)
        nameL.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(22)
            make.left.equalTo(iconv.snp.right).offset(8)
        }
        self.contentView.addSubview(timeL)
        timeL.snp.makeConstraints { (make) in
            make.left.equalTo(nameL)
            make.top.equalTo(nameL.snp.bottom).offset(4)
        }
        self.contentView.addSubview(detailL)
        detailL.snp.makeConstraints { (make) in
            make.left.equalTo(nameL)
            make.top.equalTo(timeL.snp.bottom).offset(8)
        }
        self.contentView.addSubview(commentBut)
        commentBut.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(29)
            make.right.equalToSuperview().offset(-10)
        }
        self.contentView.addSubview(loveBut)
        loveBut.snp.makeConstraints { (make) in
            make.centerY.equalTo(commentBut)
            make.right.equalTo(commentBut.snp.left).offset(-8)
        }
    }
    lazy var iconv :UIImageView = {
      let imgv = UIImageView()
        imgv.sdsSize = CGSize(width: 34, height: 34)
        imgv.cornor(conorType: .allCorners, reduis: 17)
        imgv.isUserInteractionEnabled = true
        imgv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapAvatarEvent(sender:))))
        return imgv
    }()
    lazy var nameL:UILabel = {
        let  lab = UILabel.createLabWith(title: "测试名字", titleColor: .Hex("#080808"), font: .pingfangSC(14))
        return lab
    }()
    lazy var loveBut:UIButton = {
        let but = UIButton.createButWith(title: "0", titleColor: .Hex("#959595"), font: .pingfangSC(13), image: #imageLiteral(resourceName: "icon_dianzan1")) {[weak self] (but) in
           if let blcok = self?.UserLoveBlock{
            blcok(but.isSelected,"1",String(self!.model.remarkId))
            }
        }
        but.setButType(type: .imgLeft, padding: 8)
        but.setImage(#imageLiteral(resourceName: "icon_shoucang"), for: .selected)
        return but
    }()
    lazy var commentBut:UIButton = {
        let but = UIButton.createButWith(title: "0", titleColor: .Hex("#959595"), font: .pingfangSC(13), image: UIImage(named: "")) { (but) in
                 
             }
        but.setButType(type: .imgLeft, padding: 8)
             return but
    }()
    lazy var timeL:UILabel = {
        let lab = UILabel.createLabWith(title: "202022020", titleColor: .Hex("#9c9c9c"), font: .pingfangSC(11))
        return lab
    }()
    lazy var detailL:UILabel = {
          let  lab = UILabel.createLabWith(title: "这是个假的评论啊", titleColor: .Hex("#080808"), font: .pingfangSC(17))
        return lab
      }()
    
    
    //MARK: - setModel
    func setModel(model:RemarkModel){
        self.model = model
        iconv.loadUrl(urlStr: model.userLogo, placeholder: #imageLiteral(resourceName: "defult_user"),size:CGSize(width: 34, height: 34))
        nameL.text = model.showName
        timeL.text = model.createTime
        detailL.text = model.issueContent
        loveBut.isSelected = model.isRmkLike
        loveBut.setTitle("\(model.issueRemkLikeCount)", for: .normal)
        commentBut.setTitle("\(model.issueReplyList)", for: .normal)
    }
}

extension CircleCommentCell {
    @objc func onTapAvatarEvent(sender: UITapGestureRecognizer) {
        tapAvatar?(model)
    }
}
