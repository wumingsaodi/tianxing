//
//  SDSScrollColltionView.swift
//  TianXin
//
//  Created by SDS on 2020/9/19.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
//class SDSScrollColltionViewCell: UICollectionViewCell {
//    var vcView:UIView?
//   func setVCView(view:UIView){
////    if vc {
////        <#code#>
////    }
//    }
//}

class SDSScrollColltionView: UIView {
    var perView:UIView?
    var VCs:[UIViewController] = [UIViewController](){
        didSet{
            self.collectionV.reloadData()
        }
    }
    var didScrollBlock:((Int)->Void)?
    lazy var collectionV:UICollectionView = {
        
        let collect = UICollectionView.init(frame: .zero, collectionViewLayout: setLayout())
        collect.showsVerticalScrollIndicator = false
        collect.showsHorizontalScrollIndicator = false
        collect.delegate = self
        collect.dataSource = self
        collect.isPagingEnabled = true
        collect.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "sdsScorllView")
        return collect
    }()
    func  setLayout() -> UICollectionViewFlowLayout {
        let lay = UICollectionViewFlowLayout()
        lay.scrollDirection = .horizontal
        lay.itemSize = CGSize(width: 10, height: 10)
        lay.minimumInteritemSpacing = 0
        lay.minimumLineSpacing = 0
       return lay
    }
    init(VCs:[UIViewController],didScrollBlock:@escaping ((Int)->Void)){
      super.init(frame: .zero)
        self.VCs = VCs
        self.didScrollBlock = didScrollBlock
        self.addSubview(collectionV)
        
        collectionV.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    override func didMoveToWindow() {
        let parentvc = self.getViewController()
        for vc in self.VCs {
             parentvc?.addChild(vc)
        }
       
    }
    func scollToIndex(index:Int) {
        collectionV.scrollToItem(at: IndexPath.init(row: index, section: 0), at: .left, animated: true)
    }
    override func layoutSubviews() {
        if  self.sdsW > 0 && self.sdsH > 0 {
            let lay  = self.collectionV.collectionViewLayout as! UICollectionViewFlowLayout
            lay.itemSize = self.sdsSize
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension SDSScrollColltionView:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return VCs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sdsScorllView", for: indexPath)
        let vc = VCs[indexPath.row]
        cell.addSubview(vc.view)
        vc.view.frame = cell.bounds
//        vc.view.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }

        return cell
    }
    
}
extension SDSScrollColltionView:UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page:Int = Int(scrollView.contentOffset.x + scrollView.sdsW*0.5) / Int(scrollView.sdsW)
        if self.didScrollBlock != nil {
            self.didScrollBlock!(page)
        }
    }
}
