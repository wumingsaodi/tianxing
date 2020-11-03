//
//  CircleRecomedTableCell.swift
//  TianXin
//
//  Created by SDS on 2020/10/2.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class CircleRecomedTableCell: UITableViewCell {
    lazy  var goodLabe:UILabel = {
       let lab =  self.createTabLab(title: "精", color: .Hex("#FFE38951"), backgroudColor: .Hex("#FFFEE6C7"))
        return lab
    }()
    lazy  var nextGoodLabe:UILabel = {
       let lab =  self.createTabLab(title: "定", color: .Hex("#FF6089CC"), backgroudColor: .Hex("#FFEEF2FB"))
        return lab
    }()
   lazy var officalTitleLab:UILabel =  {
    let lab = UILabel.createLabWith(title: "", titleColor: .Hex("#FFE38951"), font: .pingfangSC(12), aligment: .center,backGroudColor: .Hex("#FFFEE6C7"), cornorRaduis: 10, cornorType: .allCorners, padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5))
         return lab
    }()
    var pics:[String] = []
    typealias TapAvatarEvent = (CircleHomeModel) -> Void
    ///关注
    var guanZhuButClickBlock:((_ isAdd:Bool)->Void)?
    ///点赞和没点赞
    var UserLoveBlock:((_ isLike:Bool,_ type:String,_ remarkId:String?)->Void)?
    var model:CircleHomeModel = CircleHomeModel()
    var imgVH:CGFloat = .zero
    var commenttableH:CGFloat = CircleCommentCell.cellH
    
    var onTapAvatar: TapAvatarEvent?
    
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
         bgv .addSubview(iconv)
        iconv.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(10)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        //
        bgv.addSubview(nameL)
        nameL.snp.makeConstraints { (make) in
            make.centerY.equalTo(iconv)
            make.left.equalTo(iconv.snp.right).offset(10)
        }
        //
        bgv.addSubview(guanZhuBut)
        guanZhuBut.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(iconv)
            make.height.equalTo(guanZhuBut.sdsSize.height)
            make.width.equalTo(guanZhuBut.sdsW)
        }
        //
        bgv.addSubview(titleL)
        titleL.snp.makeConstraints { (make) in
            make.left.equalTo(iconv)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(iconv.snp.bottom).offset(10)
        }
        //
        bgv.addSubview(officalTitleLab)
        officalTitleLab.snp.makeConstraints { (make) in
            make.height.equalTo(0.1)
            make.left.equalTo(iconv)
            make.top.equalTo(titleL.snp.bottom).offset(5)
        }
        //
        bgv.addSubview(imgvs)
        imgvs.snp.makeConstraints { (make) in
            make.left.equalTo(iconv)
            make.right.equalTo(titleL)
            make.top.equalTo(officalTitleLab.snp.bottom).offset(5)
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
        // 添加头像点击事件
        let tapAvatar = UITapGestureRecognizer(target: self, action: #selector(onTapAvatar(gesture:)))
        iconv.addGestureRecognizer(tapAvatar)
    }
    lazy var timeL:UILabel = {
        let lab = UILabel.createLabWith(title: "2020-11-14", titleColor: .Hex("#9C9C9C"), font: .pingfangSC(13))
        return lab
    }()
    lazy var loveBut:UIButton = {
        let but = UIButton.createButWith(title: "0", titleColor: .Hex("#9C9C9C"), font: .pingfangSC(13), image: #imageLiteral(resourceName: "icon_dianzan1")) {[weak self] (but) in
            if let block = self?.UserLoveBlock {
                block(but.isSelected,"0",nil)//帖子
            }
            
        }
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
            ncell.tapAvatar = { model in
                let vc = UserDetailViewController.`init`(withUserId: model.userId.toString())
                self?.viewController()?.navigationController?.pushViewController(vc, isNeedLogin: true, animated: true)
            }
            ncell.setModel(model: model!)
        }, height: { (_) -> CGFloat in
            return CircleCommentCell.cellH
        }).sdsDidSelectCell { [weak self](indexPath) in
            guard let self = self,
                  let vc = R.storyboard.circle.issueCommentReplyViewController()
            else { return }
            let remark = self.model.remarkList[indexPath.row]
            
            vc.viewModel = IssueCommentReplyViewControllerModel(remarkId: "\(remark.remarkId)")
            self.viewController()?.navigationController?.pushViewController(vc, isNeedLogin: true, animated: true)
        }
        return tab
    }()
    lazy var  imgvs :UIView = {
      let view = UIView()
        return view
    }()
    lazy  var iconv:UIImageView = {
    let imgv = UIImageView()
        imgv.isUserInteractionEnabled = true
        imgv.cornor(conorType: .allCorners, reduis: 22, borderWith: 1, borderColor: mainYellowColor)
        return imgv
    }()
    lazy var nameL:UILabel = {
        let lab = UILabel.createLabWith(title: "测试名字", titleColor: .Hex("#FF5C5C5C"), font: .pingfangSC(18))
        return lab
    }()
    lazy var guanZhuBut:UIButton = {
        let but = UIButton.createButWith(title: "关注", titleColor: mainYellowColor, font: .pingfangSC(14), image: #imageLiteral(resourceName: "icon_guanzhu"),  backGroudColor: .clear) {[weak self] (but) in
            if let block = self?.guanZhuButClickBlock {
                block(!self!.model.isAttention)
            }
        }
        but.sdsSize = CGSize(width: 70, height: 28)
        but.cornor(conorType: .allCorners, reduis: 14, borderWith: 1, borderColor: mainYellowColor)
        but.setButType(type: .imgLeft, padding: 5)
        return but
    }()
    var titleL:UILabel = {
        let lab = UILabel.createLabWith(title: "测试文字测试文字测试", titleColor: nil, font: .pingfangSC(15))
        lab.numberOfLines = 0
        return lab
    }()
    func createTabLab(title:String,color:UIColor,backgroudColor:UIColor)->UILabel{
        let lab = UILabel.createLabWith(title: title, titleColor: color, font: .pingfangSC(12), cornorRaduis: 4, cornorType: .allCorners, padding: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
        lab.backgroundColor = backgroudColor
        return  lab
    }
    func guanzhuBut(slected:Bool){
        if slected {
            guanZhuBut.setImage(UIImage(), for: .normal)
            guanZhuBut.setTitle("已关注", for: .normal)
            guanZhuBut.cornor(conorType: .allCorners, reduis: guanZhuBut.sdsH*0.5, borderWith: 0, borderColor: .clear)
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
        let imgeWH:CGFloat = scaleX(100)
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
                imgv.rx.tapGesture().when(.ended).subscribe(onNext: { [weak self] _ in
                    let vc = PhotoBrowser(photos: self!.pics, initialPageIndex: i, fromView: imgv)
                if let  parentvc = self!.getViewController(){
                    parentvc.present(vc, animated: true, completion: nil)
                }
                }).disposed(by: rx.disposeBag)
                imgViews.append(imgv)
            }
            imgv.tag = i
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
    func setModel(model:BaseModel){
        let model = model as! CircleHomeModel
        self.model = model
        iconv.loadUrl(urlStr: model.userLogo, placeholder:#imageLiteral(resourceName: "defult_user"))
        nameL.text = model.showName
        guanzhuBut(slected: model.isAttention)
        
        titleL.text =  "          " + model.issueContent
        if model.officialLikeCount > 100 {//精
            self.nextGoodLabe.removeSubviews()
            self.contentView.addSubview(self.goodLabe)
            goodLabe.snp.remakeConstraints { (make) in
                make.left.top.equalTo(titleL)
            }
        }else  if model.officialLikeCount > 50 {//顶
            self.goodLabe.removeSubviews()
            self.contentView.addSubview(self.nextGoodLabe)
            nextGoodLabe.snp.remakeConstraints { (make) in
                make.left.top.equalTo(titleL)
            }
        }else{
            goodLabe.removeSubviews()
            nextGoodLabe.removeSubviews()
        }
        //
        if model.issueTitle.count  > 0 {
            officalTitleLab.snp.remakeConstraints { (make) in
                make.height.equalTo(20)
                make.left.equalTo(titleL)
                make.top.equalTo(titleL.snp.bottom).offset(5)
            }
        }else{
            officalTitleLab.snp.remakeConstraints { (make) in
                make.height.equalTo(0.1)
                make.left.equalTo(titleL)
                make.top.equalTo(titleL.snp.bottom).offset(5)
            }
        }
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
        loveBut.isSelected = model.isIssueLike
        commentBut.setTitle("\(model.squareRemarkCount)", for: .normal)
    }
}

// MARK: - events
extension CircleRecomedTableCell {
    @objc fileprivate func onTapAvatar(gesture: UITapGestureRecognizer) {
        onTapAvatar?(self.model)
    }
}
