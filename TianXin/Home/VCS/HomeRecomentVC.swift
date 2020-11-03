//
//  HomeRecomentVC.swift
//  TianXin
//
//  Created by SDS on 2020/10/14.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import XRCarouselView
class HomeRecomentVC: SDSBaseVC {
    var orginY:CGFloat = 0
    weak var homeparenvc:HomeVC?
    let headTitles:[String] = ["最新更新","中文无码","国产偷拍"]
    var indexModel:HomeIndexModel = HomeIndexModel(){
        didSet{
            collectV.reloadData()
        }
    }
    lazy var vm:HomeViewModel = {
        return HomeViewModel()
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    func setUI(){
        self.view.addSubview(collectV)
        collectV.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    lazy var collectV:SDSCollectionView = {
        //        let lay = HomeLayOut()
        let lay =  UICollectionViewFlowLayout()
        //        let width = (Configs.Dimensions.screenWidth - 20 - 30)/2
        //        lay.itemSize = CGSize(width: width, height: 170)
        //        lay.headerReferenceSize = CGSize(width: Configs.Dimensions.screenWidth, height: 30)
        //        lay.footerReferenceSize = CGSize(width: Configs.Dimensions.screenWidth, height: 44)
        lay.sectionInset = UIEdgeInsets(top: 5, left: 10, bottom: 0, right: 10)
        
        let collect = SDSCollectionView.init(frame: .zero, collectionViewLayout: lay)
        collect.dataSource = self
        collect.delegate = self
        collect.backgroundColor = .white
        //header
        collect.register(HomeRecommendHeadFirst.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeRecommendHeadFirst.className())
        collect.register(HomeCollectionCellHeader.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader , withReuseIdentifier: HomeCollectionCellHeader.className())
        // footer
        collect.register(DefualtColleCtionFoot.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: DefualtColleCtionFoot.className())
        collect.register(HomeRecomendFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: HomeRecomendFooter.className())
        //
        collect.register(DefultCell.self, forCellWithReuseIdentifier: DefultCell.className())
        collect.register(UINib.init(nibName: "HomeCell", bundle: nil), forCellWithReuseIdentifier: HomeCell.className())
        return  collect
    }()
}


//MARK: - actions
extension HomeRecomentVC:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: 1, height: 1)
        }
        let width = (Configs.Dimensions.screenWidth - 20 - scaleX(30))/2
        return CGSize (width: width, height: 151)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: Configs.Dimensions.screenWidth, height: HomeRecommendHeadFirst.headH)
        }
        return CGSize(width: Configs.Dimensions.screenWidth, height: 30)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: Configs.Dimensions.screenWidth, height: 1)
        }
        return CGSize(width: Configs.Dimensions.screenWidth, height: 44)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if  section == 0 {
            return 1
        }else if section == 1 {
            return indexModel.hotList.count
        }else if section == 2 {
            return  indexModel.chineseList.count
        }else if section == 3 {
            return indexModel.touList.count
        }
        return 0
    }
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  4
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DefultCell.className(), for: indexPath)
            return  cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCell.className(), for: indexPath) as! HomeCell
        if indexPath.section == 1 {
            if indexModel.hotList.count > 0 {
                cell.setModel(model: indexModel.hotList[indexPath.row])
            }
            
        } else if indexPath.section == 2 {
            if indexModel.chineseList.count > 0 {
                cell.setModel(model: indexModel.chineseList[indexPath.row])
            }
        }
        else if indexPath.section == 3 {
            if indexModel.touList.count > 0 {
                cell.setModel(model: indexModel.touList[indexPath.row])
            }
        }
        
        return  cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            if indexPath.section == 0 {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DefualtColleCtionFoot.className(), for: indexPath)
                return  footer
            }
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HomeRecomendFooter.className(), for: indexPath) as! HomeRecomendFooter
            footer.refreshBlock = {[weak self] in
                var type = self!.indexModel.hotListType
                switch indexPath.section {
                case 2:
                    type = self!.indexModel.chineseListType
                case 3:
                    type = self!.indexModel.touListType
                default:
                    break
                }
                self!.vm.HomeIndexRefresh(type: type) { (models) in
                    if type ==  self!.indexModel.hotListType{
                        self!.indexModel.hotList = models
                        self!.collectV.reloadSections([1])
                    }else  if type ==  self!.indexModel.chineseListType{
                        self!.indexModel.chineseList = models
                        self!.collectV.reloadSections([2])
                    }else  if type ==  self!.indexModel.touListType{
                        self!.indexModel.touList = models
                        self!.collectV.reloadSections([3])
                    }
                }
            }
            return  footer
        }
        if indexPath.section == 0 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HomeRecommendHeadFirst.className(), for: indexPath) as! HomeRecommendHeadFirst
            return header
        }
        let header =  collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HomeCollectionCellHeader.className(), for: indexPath) as! HomeCollectionCellHeader
        header.setHeadText(text: headTitles[indexPath.section - 1])
        return  header
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var modes = indexModel.hotList
        switch indexPath.section {
        case 2: modes = indexModel.chineseList
        case 3: modes = indexModel.touList
        default:
            break
        }
        
        
        let item = modes[indexPath.row]
        HomeDetailViewMoodel().requistMovieDetail(id: item.id) { (model) in
            let vc = HomeDetailVC()
            vc.model = model
            self.homeparenvc!.navigationController?.pushViewController(vc,isNeedLogin: true, animated: true)
        }
    }
}


extension HomeRecomentVC:UIScrollViewDelegate{
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
                }// - (scrollView.contentSize.height - scrollView.bounds.size.height) )
            }
        }
        orginY = scrollView.contentOffset.y
    }
}

class DefualtColleCtionFoot: UICollectionReusableView {
}

