//
//  MineVC.swift
//  TianXin
//
//  Created by SDS on 2020/9/18.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
class MineVC: SDSBaseVC {
    let leftRightMargin:CGFloat = 12
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        LocalUserInfo.share.updateLoginSate {[weak self] (islogin) in
            if islogin {
                self?.loginedView.isHidden = false
                self?.nologinV.isHidden = true
                LocalUserInfo.share.getLoginInfo {[weak self] (model) in
                    guard let model = model else{
                        self?.nologinV.isHidden = false
                        self?.loginedView.isHidden = true
                        return
                    }
                    self?.nameL.text = model.nickName
                    self?.iconV.loadUrl(urlStr: model.userLogo, placeholder: "defult_user")
                    
                  
                }
            }else{
                self?.iconV.image = #imageLiteral(resourceName: "icon_Avatar")
//                self?.iconV.image = UIImage(named: "icon_Avatar")
                self?.nologinV.isHidden = false
                self?.loginedView .isHidden = true
            }
        }
        LocalUserBalance.share.getUserBalance { [weak self](model) in
            self?.tianxinMoneyL.text =  String(format: "%0.2f", model.balance)
            self?.kOKmoneyL.text = String(format: "%0.2f", model.totalAssets)
            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    func setUI(){
        let headV = UIView()
        headV.backgroundColor = .white
        self.view.addSubview(headV)
        headV.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(134 + kStatueH)
        }
        headV.addSubview(topBgImgView)
        topBgImgView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
        headV.addSubview(iconV)
        iconV.snp.makeConstraints { (make) in
//            make.centerY.equalToSuperview().offset(kStatueH)
            make.bottom.equalToSuperview().offset(-25)
            make.left.equalToSuperview().offset(16.5)
            make.size.equalTo(CGSize(width: 72, height: 72))
        }
        headV.addSubview(nologinV)
        nologinV.isHidden = true
        nologinV.snp.makeConstraints { (make) in
            make.top.right.bottom.equalToSuperview().offset(kStatueH)
            make.left.equalTo(iconV.snp.right).offset(15)
        }
        //
        headV.addSubview(loginedView)
        loginedView.isHidden = false
        loginedView.snp.makeConstraints { (make) in
//            make.top.right.bottom.equalToSuperview().offset(kStatueH)
            make.left.equalTo(iconV.snp.right).offset(25)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(134)
        }
        //
        let monyViews = cretatmoneyViews()
        self.view.addSubview(monyViews)
        
        let maxWidthContainer: CGFloat = 350
        let maxHeightContainer: CGFloat = 167
        
        monyViews.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftRightMargin)
            make.right.equalToSuperview().offset(-leftRightMargin)
            make.top.equalTo(headV.snp.bottom).offset(10)
            make.height.equalTo(monyViews.snp.width).multipliedBy(maxHeightContainer/maxWidthContainer)
        }
//        print("宽：\(monyViews.width) 高：\(monyViews.height)")
        //
        let itemsv = createitemsView()
        self.view.addSubview(itemsv)
        itemsv.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftRightMargin)
            make.right.equalToSuperview().offset(-leftRightMargin)
            make.top.equalTo(monyViews.snp.bottom).offset(10)
            make.height.equalTo(90)
        }
        //
        self.view.addSubview(tableView)
        tableView.isScrollEnabled = true
        tableView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftRightMargin)
            make.right.equalToSuperview().offset(-leftRightMargin)
            make.top.equalTo(itemsv.snp.bottom).offset(10)
            //make.height.equalTo(44*3)
            make.bottom.equalTo(self.view.safeAreaInsets.bottom)
            //            make.bottom.equalToSuperview()
        }

    }
    func createitemsView()->UIView{
        let bgv = UIView()
        bgv.backgroundColor = .white
        bgv.cornor(conorType: .allCorners, reduis: 7.5)
        let titles = ["我要推广","充值中心","任务中心","我的收藏"]
        let imgNames = ["icon_Promote","icon_recharge centre","icon_task","icon_Collect"]
//       let vc  =    R.storyboard.topic.movieFavoritesViewController
          
        let  shoucangvc = MovieFavoritesViewController.instanceFrom(storyboard: "Topic")
        let vcs:[UIViewController] = [TuiguangVC(),RechargeVC(),MineTaskCenterVC(),shoucangvc]
        let butw:CGFloat = (Configs.Dimensions.screenWidth - 20)/4
        var x:CGFloat = 0
        let font = UIFont(name: "PingFangSC-Medium", size: 15)
        for i in 0..<titles.count {
            let but = UIButton.createButWith(title: titles[i], titleColor: .Hex("#FF87827D"), font: font, image: UIImage(named: imgNames[i])) { (_) in
                self.navigationController?.pushViewController(vcs[i],isNeedLogin: true, animated: true)
            }
            
            but.setButType(type: .imgTop, padding: 5)
            bgv.addSubview(but)
            but.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().offset(x)
            }
            x += butw
        }
        
        return bgv
    }
    
    func  cretatmoneyViews() -> UIView {
        let bgv = UIView()
        bgv.backgroundColor = .white
        bgv.cornor(conorType: .allCorners, reduis: 7.5)
        let tianMoneyv =   createMoneyView(backgroudImg: UIImage(named: "qianbao0")!, detailTxt: "甜杏钱包（元）", isTianxin: true)
        bgv.addSubview(tianMoneyv)
        tianMoneyv.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().offset(-25)
//            make.size.equalTo(CGSize(width: 300, height: 69))
        }
        let kokMoneyv =   createMoneyView(backgroudImg: UIImage(named: "qianbao1")!, detailTxt: "游戏钱包（元）", isTianxin: false)
        bgv.addSubview(kokMoneyv)
        kokMoneyv.snp.makeConstraints { (make) in
            make.top.equalTo(tianMoneyv.snp.bottom).offset(7.5)
            make.left.equalTo(tianMoneyv.snp.left)
            make.right.equalTo(tianMoneyv.snp.right)
            make.bottom.equalToSuperview().offset(-11)
            make.height.equalTo(tianMoneyv.snp.height)
//            make.centerX.equalToSuperview()
//            make.size.equalTo(CGSize(width: 300, height: 69))
        }
        return bgv
    }
    func loginStatueChange(islogin:Bool){
        if islogin {
            nologinV.isHidden = true
            loginedView.isHidden = false
        }else{
            nologinV.isHidden = false
            loginedView.isHidden = true
        }
    }
    func createMoneyView(backgroudImg:UIImage,detailTxt:String,isTianxin:Bool)->UIImageView{
        let bgv = UIImageView()
        bgv.isUserInteractionEnabled = true
        var tap:UITapGestureRecognizer!
        if isTianxin {
            tap = UITapGestureRecognizer.init(target: self, action: #selector(jumpToTianXingMoneyVC))
        }else
        {
            tap = UITapGestureRecognizer.init(target: self, action: #selector(jumpToTianXingMoneyVC))
        }
        bgv.addGestureRecognizer(tap)
        bgv.contentMode = .scaleToFill
        bgv.image = backgroudImg
        
        let toplab = UILabel.createLabWith(title: "0", titleColor: .white, font: .pingfangSC(20))
        if isTianxin {
            tianxinMoneyL = toplab
        }else{
            kOKmoneyL = toplab
        }
        bgv.addSubview(toplab)
        toplab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(75)
            make.top.equalToSuperview().offset(14)
        }
        let detailL = UILabel.createLabWith(title: detailTxt, titleColor: .white, font: .pingfangSC(12))
        detailL.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        bgv.addSubview(detailL)
        detailL.snp.makeConstraints { (make) in
            make.left.equalTo(toplab)
            make.top.equalTo(toplab.snp.bottom)
        }
        return bgv
    }
    
    lazy var topBgImgView:UIImageView = {
        let imgv = UIImageView()
        imgv.image = UIImage.init(named: "mine_background")
        return imgv
    }()
    
    lazy var iconV:UIImageView = {
        let imgv = UIImageView()
        imgv.cornor(conorType: .allCorners, reduis: 36)
        imgv.image = UIImage.init(named: "icon_Avatar")
        return imgv
    }()
    lazy var nologinV:UIView = {
        let view = UIView()
        let but = UIButton.createButWith(title: "登陆/注册", titleColor: mainYellowColor, font: UIFont(name: "PingFangSC-Regular", size: 18)){ (_) in
            let loginVC = LoginVC()
            self.navigationController?.pushViewController(loginVC, animated: true)
        }
        but.cornor(conorType: .allCorners, reduis: 15.5,borderWith: 10,borderColor: mainYellowColor)
        view.addSubview(but)
        but.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(50)
            make.size.equalTo(CGSize(width: 117.5, height: 31))
        }
        let lab = UILabel.createLabWith(title: "登陆后获取更多精彩内容哦～", titleColor: .Hex("#FF686868"), font: UIFont(name: "PingFangSC-Regular", size: 15))
        view.addSubview(lab)
        lab.snp.makeConstraints { (make) in
            make.left.equalTo(but)
            make.top.equalTo(but.snp.bottom).offset(8)
            //            make.right.equalToSuperview()
            //            make.bottom.equalToSuperview()
        }
        return view
    }()
    lazy var nameL:UILabel = {
        let font = UIFont(name: "PingFangSC-Regular", size: 23)
        let lab = UILabel.createLabWith(title: "", titleColor: .Hex("#FF918C88"), font: font)
        return lab
    }()
    lazy var loginedView:UIView = {
        let view = UIView()
//        view.backgroundColor = .red
        view.addSubview(nameL)
        nameL.snp.makeConstraints { (make) in
//            make.left.centerY.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-50)
        }
        let but = UIButton.createButWith( image: UIImage(named: "Back_more")) { (_) in
            let vc = mineSettingVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        view.addSubview(but)
        but.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-50)
//            make.top.bottom.equalToSuperview().offset(-20)
            make.width.equalTo(50)
        }
        return view
    }()
    var tianxinMoneyL:UILabel!
    var kOKmoneyL:UILabel!
    lazy var tableView:SDSTableView = {
        let tab = SDSTableView.CreateTableView().sdsNumOfRows(block: { (_) -> Int in
            return 3
        }) .sdsRegisterCell(cellClass: mineTableCell.className(), cellBlock: { (indepath, cell) in
            let ncell = cell as! mineTableCell
            if indepath.row == 0 {
                ncell.setcell(imgName: "icon_kefu", text: "联系客服")
            }else if indepath.row == 1 {
                ncell.setcell(imgName: "icon_setting", text: "系统设置")
            }else if indepath.row == 2 {
                ncell.setcell(imgName: "icon_about us", text: "关于我们")
            }
        },height: { (_) -> CGFloat in
            return 44
        }).sdsDidSelectCell { (indepath) in
            if indepath.row == 0 {//联系客服
                let vc = KefuVC()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if indepath.row == 1 {//系统设置
                let vc = SettingVC()
                self.navigationController?.pushViewController(vc,isNeedLogin: true, animated: true)
            }else if indepath.row == 2 {//关于我们
                let vc = AboutUS()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        tab.separatorStyle = .none
        tab.sdsCornorReduis = 7.5
        return tab
    }()
}


extension MineVC {
    @objc   func   jumpToTianXingMoneyVC(){
        let vc = TianXingQianBaoVC.init(nibName: "TianXingQianBaoVC", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
//    @objc   func   jumpToKOKMoneyVC(){
//        let vc = KOKMoneyVC.init(nibName: "KOKMoneyVC", bundle: nil)
//               self.navigationController?.pushViewController(vc, animated: true)
//    }
}







class  mineTableCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .white
        setUI()
    }
    func setcell(imgName:String,text:String)  {
        self.imgv.image = UIImage(named: imgName)
        self.textL.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy  var imgv:UIImageView = {
        let imgv = UIImageView()
        return imgv
    }()
    lazy var textL:UILabel  = {
        let font = UIFont(name: "PingFangSC-Medium", size: 15)
        let lab = UILabel.createLabWith(title: "", titleColor: .Hex("#FF87827D"), font: font)
        return lab
    }()
    func setUI() {
        //
        self.contentView.addSubview(imgv)
        imgv.snp.makeConstraints { (make) in
            make.left.equalTo(17.5)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 34.5, height: 34.5))
        }
        //
        self.contentView.addSubview(textL)
        
        textL.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(imgv.snp.right).offset(15)
        }
        //
        let subimgv = UIImageView(image: UIImage(named: "Back_more"))
        self.contentView.addSubview(subimgv)
        subimgv.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-14)
        }
    }
    
}


