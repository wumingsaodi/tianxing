//
//  HomeVC.swift
//  TianXin
//
//  Created by SDS on 2020/9/18.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import XRCarouselView
import RxSwift
import RxCocoa
//import LLCycleScrollView
class HomeVC: UIViewController {
    let maxOffsetY:CGFloat = 170
    let leftRightMargin:CGFloat = 10
    var index_banner : [BannerItemModel] = []
    var childVcs:[UIViewController] =  [UIViewController]()
    var isLeavehomeVC :Bool = false{
        didSet{
            LocalUserBalance.share.getUserBalance {[weak self] (balace) in
                if balace.balance < 50 {
//                    _ =   HomeMoneyPopView.ShowSDSCover(istap: false)
//                    return 
                    
                    if  Date().timeIntervalSince1970  -  UserDefaults.standard.double(forKey: NoHomeMoenyPopShow) > 3600*24{
                        if !(self?.isLeavehomeVC ?? true ){//只在首页显示
                         _ =   HomeMoneyPopView.ShowSDSCover(istap: false)
                        }
                        
                    }
                 
                }
            }

        }
    }
    lazy var homevm :HomeViewModel = {
      let vm = HomeViewModel()
        return vm
    }()
  
    lazy var  topView:HometopSearchView = {
        let top = HometopSearchView()
        return top
    }()
    lazy var titleView:SDSScrollTitlesView = {
        let titles =  ["推荐"]   // ["关注","推荐","游戏","国产","中文无码"]
        let width:CGFloat =  83  //(Configs.Dimensions.screenWidth - 40) / CGFloat(titles.count)
        let view = SDSScrollTitlesView(ttles: titles, width: width) {[weak self] (index, cell) in
            self?.vcsCollectionv.scollToIndex(index: index)
        }
        return view
    }()

    lazy var itemScrollorViews:HomeDownBannerItemView = {
        let itemv = HomeDownBannerItemView()
        return itemv
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = true
        self.isLeavehomeVC = false
        self.extendedLayoutIncludesOpaqueBars = true
        self.navigationController?.navigationBar.isHidden = true
        self.view.backgroundColor = .white
        NotificationCenter.default.rx.notification(.HomeMenuOnTap)
            .compactMap({$0.object as? typeItmeModel})
            .asObservable()
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                if let index = self.homevm.homeModel?.type.firstIndex(of: model) {
                    self.titleView.scollToIndex(index: index + 1)
                    self.vcsCollectionv.scollToIndex(index: index + 1)
//                    self.perform(block: {
//                        self.titleView.scollToIndex(index: index + 1)
//                    }, timel: 0.25)
                }
            })
            .disposed(by: rx.disposeBag)
        
        setUI()

        self.perform(#selector(FirstScroll), with: nil, afterDelay: 0.25)
    }
    
    func  setUI(){
        self.view.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(kStatueH + 15 )
            make.height.equalTo(30)
        }
        //
         self.view.addSubview(titleView)

        titleView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview() //.offset(-40)
            make.top.equalTo(topView.snp.bottom).offset(8)
            make.height.equalTo(30)
        }
        //
        self.view .addSubview(bgScollv)
        bgScollv.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kbottomtoolBar - 5)
            make.top.equalTo(titleView.snp.bottom)
        }
        bgScollv.contentLayoutGuide.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()    //equalTo  (titleView.snp.bottom)
            make.bottom.equalToSuperview().offset(maxOffsetY)
        }
        bgScollv.addSubview(bannerView)
        bannerView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftRightMargin)
            make.right.equalToSuperview().offset(-leftRightMargin)
            make.top.equalToSuperview()
            make.height.equalTo(168.5)
        }
        //
        bgScollv.addSubview(vcsCollectionv)
        vcsCollectionv.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(bannerView.snp.bottom).offset(5)
            
        }
    }
    lazy var bgScollv:UIScrollView = {
        let bgscollv = UIScrollView()
        bgscollv.delegate = self
        bgscollv.showsHorizontalScrollIndicator = false
        bgscollv.showsVerticalScrollIndicator = false
        return bgscollv
    }()
    /**
     轮播图
     */
        lazy var bannerView:XRCarouselView = {
            let  bannar = SDSBanar().createBarnarView()
            let currimg = UIImage(named: "oval")
            let  normalimg = UIImage(named: "ring")
//            bannar.setPageImage(normalimg, andCurrentPageImage: currimg)
            LocalUserInfo.share.getBanar { [weak self , weak bannar](model) in
                guard let  bannar = bannar else{
                    return
                }
                self?.index_banner  = model.index_banner
                let titles = model.index_banner.map { (bannar) -> String in
                    return bannar.coverUrl
                }
                bannar.imageArray = titles
            }
            bannar.imageClickBlock = {[weak self] index in
                guard let self = self else{
                    return
                }
                let webvc = SDSBaseWebVC.init(url: self.index_banner[index].adUrl)
                self.navigationController?.pushViewController(webvc, animated: true)
            }
            return bannar
        }()
    lazy var vcsCollectionv:SDSScrollColltionView = {
       let vc = HomeRecomentVC()
        self.childVcs.append(vc)
        self.childVcs.append(HomeOtherSubVC())
        let collv = SDSScrollColltionView(VCs: self.childVcs) {[weak self] (index) in
            self?.titleView.scollToIndex(index: index)
        }
        return collv
    }()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isLeavehomeVC = false
        self.navigationController?.navigationBar.isHidden = true
        navigationItem.backButtonTitle = ""
        requistData()
    }
    @objc  func  FirstScroll(){
        self.titleView.scollToIndex(index: 0)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isLeavehomeVC = true
        self.navigationController?.navigationBar.isHidden = false
//        self.hidesBottomBarWhenPushed = true
    }

}


extension HomeVC:UIScrollViewDelegate{
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView == bgScollv {
//           if scrollView.contentOffset.y >= maxScrollY{
//                scrollView.contentOffset = CGPoint(x: 0, y: maxScrollY)
//             let vc  =    self.childVcs[0] as! HomeRecomentVC
//            vc.collectV.collectionvewShouldBeigin = true
////            vc.collectV.isScollTogatherWithOther = false
//            for i in 1..<childVcs.count {
//                let othervc = childVcs[i] as! HomeOtherSubVC
//                othervc.collectionv.collectionvewShouldBeigin = true
////                othervc.collectionv.isScollTogatherWithOther = false
//            }
//            }
//        }
//    }
    func setScroll(vc:SDSBaseVC) {
        vc.tableViewScrollToTopOrBottom = { [weak self](isTop,offsety) in
//            NJLog("\(offsety)")
            let offset = self!.bgScollv.contentOffset
            if isTop {
                self?.bgScollv.contentOffset =  CGPoint(x: offset.x, y: offset.y + offsety)
                if offset.y <= 0 {
                    self?.bgScollv.contentOffset =  CGPoint(x: offset.x, y: 0)
                    return true
                }
return  false
//                    self?.bgscrollv.setContentOffset(CGPoint(x: offset.x, y:offset.y + offsety ), animated: false)
            }else{

                self?.bgScollv.contentOffset =  CGPoint(x: offset.x, y: offset.y + offsety)
                if offset.y >= self!.maxOffsetY {
                    self?.bgScollv.contentOffset =  CGPoint(x: offset.x, y: self!.maxOffsetY)
                        return true
                }
                if offset.y < 0 {
                    self?.bgScollv.contentOffset =  CGPoint(x: offset.x, y: 0)
                }
                return false
//                    self?.bgscrollv.setContentOffset(CGPoint(x: offset.x, y: offset.y + offsety), animated: true)
            }
        }

    }
    
    
}


extension HomeVC{
    func  requistData() {
        homevm.RequistHomeIndex {[weak self] in
            guard  let model =  self?.homevm.homeModel else{
                return
            }
            var  titles:[String] = ["推荐"]
            titles.append(contentsOf: model.type.map({ (iteem) -> String in
                return iteem.type
            }))
            self?.titleView.titles = titles
//            self?.FirstScroll()
            var vcs:[UIViewController] = [UIViewController]()
            for i in 0..<titles.count{
                if i == 0 {
                  let recomemnt =  HomeRecomentVC()
                    self?.setScroll(vc: recomemnt)
                    recomemnt.homeparenvc = self
                    recomemnt.indexModel = model
                    vcs.append(recomemnt)
                }else{
                    let othervc = HomeOtherSubVC()
                    self?.setScroll(vc: othervc)
                    othervc.homeparenvc = self
                    othervc.type = model.type[i - 1]
                    vcs.append(othervc)
                }
            }
            self?.childVcs = vcs
            self?.vcsCollectionv.VCs = vcs
            self?.topView.menus = model.type
        }
    }
}
