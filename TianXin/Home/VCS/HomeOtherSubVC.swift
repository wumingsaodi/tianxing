//
//  HomeOtherSubVC.swift
//  TianXin
//
//  Created by SDS on 2020/10/14.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import MJRefresh
class HomeOtherSubVC: SDSBaseVC {
    var orginY:CGFloat = 0
    
    weak var homeparenvc:HomeVC?
    var vm = HomeViewModel()
    var modes:[HomeItemModel] = [HomeItemModel]()
    var currPage:Int = 0
    var isNotMore:Bool = false
    
    var type:typeItmeModel = typeItmeModel()
//    {
//        didSet{
//        requistData()
//        }
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(collectionv)
        collectionv.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
//        requistData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currPage = 1
        requistData()
    }
    lazy var collectionv:SDSCollectionView = {
        let lay  = UICollectionViewFlowLayout()
        lay.sectionInset = UIEdgeInsets(top: 5, left: 10, bottom: 0, right: 10)
        let collevtv = SDSCollectionView.init(frame: .zero, collectionViewLayout: lay)
        collevtv.delegate = self
        collevtv.dataSource = self
        collevtv.register(DefultCell.self, forCellWithReuseIdentifier: DefultCell.className())
        
        collevtv.register(UINib(nibName: "HomeCell", bundle: nil), forCellWithReuseIdentifier: HomeCell.className())
        //header
        collevtv.register(HomeOtherVCHeadFirst.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeOtherVCHeadFirst.className())
        
        collevtv.register(HomeCollectionCellHeader.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeCollectionCellHeader.className())
        collevtv.mj_footer = MJRefreshAutoNormalFooter.init(refreshingBlock: {[weak self] in
            if self!.isNotMore {
                collevtv.mj_footer?.endRefreshing()
                return
            }
            self?.requistData()
        })
        collevtv.backgroundColor = .white
        
        return collevtv
    }()
    override func didReceiveMemoryWarning() {
        if modes.count > 20 {
            self.modes.removeSubrange(20...modes.endIndex)
        }
        
        self.currPage = 0
        self.collectionv.reloadData()
        NJLog("首页其他的控制器收到内存警告了--- \(self.modes.count)")
    }
}


//MARK: - datasours delegate
extension HomeOtherSubVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return  self.modes.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  2
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: 1, height: 1)
        }
        let width = (Configs.Dimensions.screenWidth - 20 - scaleX(30))/2
        let height = width / 175  * 151
        return CGSize(width: width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return  CGSize(width: Configs.Dimensions.screenWidth, height: HomeOtherVCHeadFirst.headH)
        }
        return  CGSize(width: Configs.Dimensions.screenWidth, height: 30)
    }
//   collectionviewlayout
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DefultCell.className(), for: indexPath)
            return cell //UICollectionViewCell()
        }else{
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCell.className(), for: indexPath) as! HomeCell
            cell.setModel(model: modes[indexPath.row])
            return cell
        }
       
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
//            return  UIView() as! UICollectionReusableView
        }else{
            if indexPath.section == 0 {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeOtherVCHeadFirst.className(), for: indexPath) as! HomeOtherVCHeadFirst
                return  header
            }else{
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeCollectionCellHeader.className(), for: indexPath) as! HomeCollectionCellHeader
                header.setHeadText(text: type.type)
                return  header
            }
        }
       return UICollectionReusableView()
       
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = modes[indexPath.row]
        HomeDetailViewMoodel().requistMovieDetail(id: item.id) { (model) in
            let vc = HomeDetailVC()
            vc.model = model
            self.homeparenvc!.navigationController?.pushViewController(vc,isNeedLogin: true, animated: true)
        }
       
    }
}


//MARK: - actions
extension HomeOtherSubVC{
    func requistData(){
        vm.requistHomeOtherList(type: String(type.id), currPage: currPage) {[weak self] (models, isNomore) in
            self?.isNotMore = isNomore
            self?.modes.append(contentsOf: models)
            self?.currPage += 1
            self?.collectionv.reloadData()
            self?.collectionv.mj_footer?.endRefreshing()
            self?.collectionv.mj_header?.endRefreshing()
        }
    }
}
extension HomeOtherSubVC:UIScrollViewDelegate{
   func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.y <= 0 { //最顶部
        if let block = tableViewScrollToTopOrBottom{
            if !block(true,scrollView.contentOffset.y - orginY){
                scrollView.contentOffset.y = 0
            }
        }
    }//else if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height {//最底部了
    else {//向上
        if let block = tableViewScrollToTopOrBottom{
            if  !block(false,scrollView.contentOffset.y - orginY ){//
                scrollView.contentOffset.y = orginY
            } // - (scrollView.contentSize.height - scrollView.bounds.size.height) )
        }
    }
    orginY = scrollView.contentOffset.y
}}



class DefultCell: UICollectionViewCell {
}
