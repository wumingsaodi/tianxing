//
//  CircleHomeVC.swift
//  TianXin
//
//  Created by SDS on 2020/10/1.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class CircleHomeVC: SDSBaseVC {
    let maxOffsetY:CGFloat = 140
    var models:[TopRecomedModel] = [TopRecomedModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = true
        self.navigationController?.navigationBar.isHidden = true
        setUI()
        
        let vm = CircleHomeViewModel()
        vm.requisttopRecomdCellList {[weak self] (models) in
            self?.models = models
            let lastModel = TopRecomedModel()
            lastModel.recommendName = "全部"
            lastModel.recommendPic = "icon_quanbu"
            self?.models.append(lastModel)
            self?.createRecomentViews(models: self!.models)
        }
        
        FloatingButton.default.show(in: self.view) {
            if LocalUserInfo.share.userInfo?.nickName.isEmpty ?? true {
                // 未设置昵称，提醒用户设置昵称
                SDSHUD.showError("请前往个人中心设置昵称")
                return
            }
            let vc = PostingViewController.`init`(viewModel: .init(fromType: .广场))
            self.navigationController?.pushViewController(vc, isNeedLogin: true, animated: true)
        }
    }
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        selectedTittlesv.scollToIndex(index: 0)
//        self.selectedVCs.scollToIndex(index: 0)
//    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    lazy var bgScrollv:UIScrollView = {
        let bgScrollv = UIScrollView()
        return bgScrollv
    }()
    func setUI() {
        
        self.view.addSubview(bgScrollv)
        bgScrollv.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kbottomtoolBar-5)    //.offset(-6)
            make.top.equalToSuperview().offset(KnavHeight + 20)
//            make.bottom.equalToSuperview().offset(-kbottomtoolBar)
        }
        bgScrollv.contentLayoutGuide.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(KnavHeight + 20)
            //            make.height.equalTo(KScreenH - KnavHeight - 20 )
            make.bottom.equalToSuperview().offset(maxOffsetY)  //.offset(maxOffsetY - 5 - kbottomtoolBar )
            //            make.size.equalTo(CGSize(width: Configs.Dimensions.screenWidth, height: KScreenH + 100))
        }
        let whiteBgV = UIView()
        whiteBgV.backgroundColor = .white
        self.view.addSubview(whiteBgV)
        
        whiteBgV.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(KnavHeight + 20 )
        }
        whiteBgV.addSubview(searchBut)
        searchBut.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(20)
            make.size .equalTo(CGSize(width: 300, height: 29))
        }
        //
        let tuijianv = ceatetuiJianView()
        bgScrollv.addSubview(tuijianv)
        tuijianv.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview()
            make.height.equalTo(132)
        }
        //
        bgScrollv.addSubview(selectedTittlesv)
        selectedTittlesv.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(tuijianv.snp.bottom).offset(15)
            make.height.equalTo(30)
        }
        //
        bgScrollv.addSubview(selectedVCs)
        selectedVCs.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
            make.top.equalTo(selectedTittlesv.snp.bottom)
        }
    }
    lazy var selectedTittlesv:SDSScrollTitlesView = {
        let titlev = SDSScrollTitlesView.init(ttles: ["推荐","我的"], width: 60) {[weak self] (index, cell) in
            self?.selectedVCs.scollToIndex(index: index)
        }
        return titlev
    }()
    lazy var selectedVCs:SDSScrollColltionView = {
        let vc1 =  CircleRecomedTableVC()
        vc1.tableViewScrollToTopOrBottom = { [weak self](isTop,offsety) in
            
            let offset = self!.bgScrollv.contentOffset
            //            NJLog("\(offset.y)")
            //            let isTop = offset.y <= maxOffsetY
            if isTop {
                self?.bgScrollv.contentOffset =  CGPoint(x: offset.x, y: offset.y + offsety)
                if offset.y <= 0 {
                    self?.bgScrollv.contentOffset =  CGPoint(x: offset.x, y: 0)
                    return true
                }
                
                return false
                //                    self?.bgscrollv.setContentOffset(CGPoint(x: offset.x, y:offset.y + offsety ), animated: false)
            }else{
                
                self?.bgScrollv.contentOffset =  CGPoint(x: offset.x, y: offset.y + offsety)
                if offset.y >= self!.maxOffsetY {
                    self?.bgScrollv.contentOffset =  CGPoint(x: offset.x, y: self!.maxOffsetY)
                    return true
                }
                if offset.y < 0 {
                    self?.bgScrollv.contentOffset =  CGPoint(x: offset.x, y: 0)
                    
                }
            }
            return false
        }
        let vc2 =  CircleMineVC()
        vc2.tableViewScrollToTopOrBottom = { [weak self](isTop,offsety) in
            //            NJLog("\(offsety)")
            let offset = self!.bgScrollv.contentOffset
            if isTop {
                self?.bgScrollv.contentOffset =  CGPoint(x: offset.x, y: offset.y + offsety)
                if offset.y <= 0 {
                    self?.bgScrollv.contentOffset =  CGPoint(x: offset.x, y: 0)
                    return true
                }
                return false
                //                    self?.bgscrollv.setContentOffset(CGPoint(x: offset.x, y:offset.y + offsety ), animated: false)
            }else{
                
                self?.bgScrollv.contentOffset =  CGPoint(x: offset.x, y: offset.y + offsety)
                if offset.y >= self!.maxOffsetY {
                    self?.bgScrollv.contentOffset =  CGPoint(x: offset.x, y: self!.maxOffsetY)
                    return true
                }
                if offset.y < 0 {
                    self?.bgScrollv.contentOffset =  CGPoint(x: offset.x, y: 0)
                    
                }
                //                    self?.bgscrollv.setContentOffset(CGPoint(x: offset.x, y: offset.y + offsety), animated: true)
            }
            return false
        }
        
        let vcs = [vc1,vc2]
        let vcsv = SDSScrollColltionView.init(VCs: vcs) { (index) in
            //
            self.selectedTittlesv.scollToIndex(index: index)
        }
        return vcsv
    }()
    var bgv:UIView?
    func ceatetuiJianView() -> UIView {
        let bgv = UIView()
        self.bgv = bgv
        bgv.backgroundColor = .white
        let lab  = UILabel.createLabWith(title: "推荐圈子", titleColor: .black, font: .pingfangSC(20))
        let imgv = UIImageView(image: UIImage(named: "icon_button_xuanzhong"))
        bgv.addSubview(imgv)
        bgv.addSubview(lab)
        
        lab.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(5)
            make.left.equalToSuperview().offset(10)
        }
        imgv.snp.makeConstraints { (make) in
            make.left.equalTo(lab).offset(-2)
            make.centerY.equalTo(lab.snp.bottom)
        }
        bgv.cornor(conorType: .allCorners, reduis: 4)
        return bgv
    }
    func createRecomentViews(models:[TopRecomedModel]){
        
        let butw:CGFloat = 50
        let buth:CGFloat = 80
        let margin:CGFloat = (Configs.Dimensions.screenWidth - 20 - butw * CGFloat(models.count)) /  CGFloat(models.count + 1)
        var x:CGFloat = margin
        let y:CGFloat  = 30
        for i in 0..<models.count {
            let model = models[i]
            let  but = createItemBut(url: model.recommendPic, title: model.recommendName, tag: i,isNoURL: i == models.count - 1)
            bgv!.addSubview(but)
            but.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(y)
                make.left.equalToSuperview().offset(x)
                make.size.equalTo(CGSize(width: butw, height: buth))
            }
            x += margin + butw
        }
        
    }
    func  createItemBut(url:String,title:String,tag:Int,isNoURL:Bool = false)->UIView{
        let view = UIView()
        let imgv = UIImageView()
        imgv.cornor(conorType: .allCorners, reduis: 25)
        if isNoURL {
            imgv.image = UIImage(named: url)
        }else {
            
            imgv.loadUrl(urlStr: url, placeholder: #imageLiteral(resourceName: "defult_user"))
        }
        view.addSubview(imgv)
        let lab = UILabel.createLabWith(title: title, titleColor: nil, font: .pingfangSC(14))
        view.addSubview(lab)
        
        imgv.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        lab.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(imgv.snp.bottom).offset(10)
        }
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapviewClick(tap:)))
        view.tag = tag
        view.addGestureRecognizer(tap)
        return view
    }
    lazy var  searchBut:UIButton = {
        let but = UIButton.createButWith(title: "请输入你想要找的关键字", titleColor: .gray, font: .pingfangSC(15),image: UIImage(named: "seach")) {[weak self] (but) in
            let vc = CircleHomeSearchVC()
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        but.backgroundColor =   .Hex("#f7f8fc") //  baseVCBackGroudColor_grayWhite
        but.cornor(conorType: .allCorners, reduis: 14.5)
        return but
    }()
}
//MARK: - actions
extension CircleHomeVC {
    @objc  func tapviewClick(tap:UITapGestureRecognizer) {
        let view = tap.view!
        if view.tag == models.count - 1 {
            // 更多
            let vc = CircleListViewController.instanceFrom(storyboard: "Circle")
            vc.viewModel = CircleListViewControllerModel()
            self.navigationController?.pushViewController(vc, isNeedLogin: true, animated: true)
        }else {
            let model = self.models[view.tag]
            let vc = CircleUserDetailVC.init(recommendId: String(model.recommendId))
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
