//
//  CircleHomeMyIssueCell.swift
//  TianXin
//
//  Created by SDS on 2020/10/19.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
class CircleHomeMyIssueCell: UITableViewCell {
    var pics:[String] = []
    var IssueDelBlock:((_ issueId:String)->Void)?
    var UserLoveBlock:((_ isLike:Bool,_ type:String,_ remarkId:String?)->Void)?
    var model:CircleHomeModel = CircleHomeModel()
    var imgVH:CGFloat = .zero
    var commenttableH:CGFloat = CircleCommentCell.cellH
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setUI()
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUI(){
        let bgv = UIView()
//        self.hyb_lastViewInCell = bgv
//        self.hyb_bottomOffsetToCell = 15
        bgv.backgroundColor = .white
        bgv.cornor(conorType: .allCorners, reduis: 3)
        self.contentView.addSubview(bgv)
        bgv.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(10)
        }
        //
        bgv.addSubview(titleL)
        titleL.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
        }
        bgv.addSubview(deletBut)
        deletBut.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        //
        bgv.addSubview(imgvs)
        imgvs.snp.makeConstraints { (make) in
            make.left.equalTo(titleL)
            make.right.equalTo(deletBut)
            make.top.equalTo(titleL.snp.bottom).offset(5)
//            make.height.equalTo(imgVH)
        }
        //
        bgv.addSubview(commentTableView)
        commentTableView.snp.makeConstraints { (make) in
            make.top.equalTo(imgvs.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(0)
//            make.height.lessThanOrEqualTo(commenttableH*3)
        }
        //
        bgv.addSubview(timeL)
        timeL.snp.makeConstraints { (make) in
            make.left.equalTo(commentTableView)
            make.top.equalTo(commentTableView.snp.bottom).offset(14)
            make.bottom.equalToSuperview().offset(-10)
        }
       //
        bgv.addSubview(commentBut)
        commentBut.snp.makeConstraints { (make) in
            make.centerY.equalTo(timeL)
            make.right.equalToSuperview().offset(-10)
        }
        //
        bgv.addSubview(loveBut)
        loveBut.snp.makeConstraints { (make) in
            make.centerY.equalTo(timeL)
            make.right.equalTo(commentBut.snp.left).offset(-25)
        }
    }
    lazy var deletBut:UIButton = {
        let but = UIButton()
        but.setImage(#imageLiteral(resourceName: "delete"), for: .normal)
        //createButWith( image: #imageLiteral(resourceName: "delete"))
        but.addTarget(self, action: #selector(deleteIssue), for: .touchUpInside)
//        {[weak self] (but) in
//            if let block = self?.IssueDelBlock {
//                block(self!.model.issueId)
//            }
//        }
        return but
    }()
    lazy var timeL:UILabel = {
        let lab = UILabel.createLabWith(title: "2020-11-14", titleColor: .Hex("#9C9C9C"), font: .pingfangSC(13))
        return lab
    }()
    lazy var loveBut:UIButton = {
        let but = UIButton.createButWith(title: "0", titleColor: .Hex("#9C9C9C"), font: .pingfangSC(13), image: #imageLiteral(resourceName: "icon_dianzan1")) {[weak self] (but) in
        }
        but.isEnabled = false
        but.setImage(#imageLiteral(resourceName: "icon_shoucang"), for: .selected)
        but.setButType(type: .imgLeft, padding: 8)
        return but
    }()
    lazy var commentBut:UIButton = {
        let but = UIButton.createButWith(title: "0", titleColor: .Hex("#9C9C9C"), font: .pingfangSC(13), image: #imageLiteral(resourceName: "icon_liuyan")) { (but) in
        
        }
        but.setButType(type: .imgLeft, padding: 8)
        but.isEnabled = false
        return but
    }()
    lazy var commentTableView:SDSTableView = {
        let tab = SDSTableView.CreateTableView().sdsNumOfRows(block: {[weak self] (_) -> Int in
            return   self!.model.remarkList.count
        }).sdsRegisterCell(cellClass: CircleCommentCell.className(), cellBlock: {[weak self] (indePath, cell) in
            let ncell = cell as! CircleCommentCell
            ncell.UserLoveBlock = self?.UserLoveBlock
            let model = self?.model.remarkList[indePath.row]
            ncell.setModel(model: model!)
        }, height: { (_) -> CGFloat in
            return CircleCommentCell.cellH
        }).sdsDidSelectCell { (ndexPath) in
            
        }
        return tab
    }()
    lazy var  imgvs :UIView = {
      let view = UIView()
        return view
    }()
    var titleL:UILabel = {
        let lab = UILabel.createLabWith(title: "测试文字测试文字测试", titleColor: nil, font: .pingfangSC(15))
        lab.numberOfLines = 0
        return lab
    }()
    func createTabLab(title:String,color:UIColor,backgroudColor:UIColor)->UILabel{
        let lab = UILabel.createLabWith(title: title, titleColor: color, font: .pingfangSC(12), cornorRaduis: 4, cornorType: .allCorners, padding: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
        return  lab
    }
    func createEmtyViewForpics(){
        imgvs.removeSubviews()
        let emty = UIView()
        imgvs.addSubview(emty)
        emty.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    func  CreateImgsView(pics:[String]) {
        self.pics = pics
        imgvs.removeSubviews()
        let imgeWH:CGFloat =  scaleX(100)
        let margin:CGFloat = (Configs.Dimensions.screenWidth - scaleX(100*3) - 24 - 20 ) / 2
        var x:CGFloat = 0
        var y:CGFloat = 0
        for i in 0..<pics.count {
            let pic = pics[i]
            var imgv:UIImageView!
//            var isExisted :Bool = false
            if imgViews.count > i {
                imgv = imgViews[i]
//                isExisted = true
            }else{
                imgv = UIImageView()
                
                imgv.isUserInteractionEnabled = true
                imgv.rx.tapGesture().when(.ended).subscribe(onNext: { [weak self]_ in
                    let vc = PhotoBrowser(photos: self!.pics, initialPageIndex: i, fromView: imgv)
                if let  parentvc = self!.getViewController(){
                    parentvc.present(vc, animated: true, completion: nil)
                }
                }).disposed(by: rx.disposeBag)
                
                imgViews.append(imgv)
            }

            imgv.cornor(conorType: .allCorners, reduis: 8)
            imgv.loadUrl(urlStr: pic, placeholder: "",size:CGSize(width: scaleX(100), height: scaleX(100)))
            imgvs.addSubview(imgv)
//            if isExisted {
                imgv.snp.remakeConstraints { (make) in
                    make.left.equalToSuperview().offset(x)
                    make.top.equalToSuperview().offset(y)
                    make.size.equalTo(CGSize(width: imgeWH, height: imgeWH))
                    if i == pics.count - 1 {
                        make.bottom.equalToSuperview()
                    }
                }

//            }else{
//                imgv.snp.makeConstraints { (make) in
//                    make.left.equalToSuperview().offset(x)
//                    make.top.equalToSuperview().offset(y)
//                    make.size.equalTo(CGSize(width: imgeWH, height: imgeWH))
//                    if i == pics.count - 1 {
//                        make.bottom.equalToSuperview()
//                    }
//                }
//
//            }
            x += imgeWH + margin
            if pics.count == 4 {
                if x + imgeWH > imgeWH*2 + margin*2 {
                    x = 0
                    y += margin + imgeWH
                }
            }else{
                if x + imgeWH > imgeWH*3 + margin*3 {
                    x = 0
                    y += margin + imgeWH
                }
                
            }
        }
    }
    func createVideoImage(cover:String,url:String){
        imgvs.removeSubviews()
        let playvc = SDSPlayerVC.init(url: url, coverImgUrl: cover)
        playvc.isCanBeiginPlay = false
        imgvs.addSubview(playvc.view)
        playvc.view.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 325.5, height: 157.5))
            make.bottom.equalToSuperview()
        }
    }
    lazy var imgViews:[UIImageView] = {
        return [UIImageView]()
    }()
    //MARK: - setModel
    func setModel(model:CircleHomeModel){
        self.model = model
        titleL.text = model.issueContent
        if model.issuePic.count > 0 {
            let  pics = model.issuePic
            CreateImgsView(pics: pics)
        }else if model.issueVideo.count > 0 {
            let url  = model.issueVideo
            createVideoImage(cover: "", url: url)
        }else{//没有图片
           createEmtyViewForpics()
        }
        if model.remarkList.count > 2 {
            commentTableView.snp.updateConstraints { (make) in
                make.height.equalTo(CircleCommentCell.cellH*2)
            }
        }else{
            commentTableView.snp.updateConstraints { (make) in
                make.height.equalTo(CircleCommentCell.cellH * CGFloat(model.remarkList.count))
        }
    }
      commentTableView.reloadData()
        timeL.text = model.createTime
        loveBut.setTitle("\(model.issueLikeCount)", for: .normal)
        loveBut.isSelected = model.isAttention
        commentBut.setTitle("\(model.squareRemarkCount)", for: .normal)
    }
}

extension CircleHomeMyIssueCell {
    @objc func deleteIssue(){
        if let block = self.IssueDelBlock {
            block(self.model.issueId)
        }
    }
}
