//
//  SDSScrollTitlesView.swift
//  TianXin
//
//  Created by SDS on 2020/9/19.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
class titleCollectCell: UICollectionViewCell {
    lazy  var lab:UILabel! = {
        let lab = UILabel.createLabWith(title: "", titleColor: .Hex("#FF87827D"), font: UIFont.systemFont(ofSize: 17), aligment: .center)
            return lab
        
    }()
    lazy  var selectedimgV:UIImageView = {
        let img = UIImage.createImgWithColor(color: mainYellowColor)
        let  imgv = UIImageView.init(image: img)
        imgv.cornor(conorType: .allCorners, reduis: 3)
        imgv.isHidden = true
        return imgv
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
      setContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func settitle(title:String){
        lab.text = title
    }
    func setContentView(){
        self.addSubview(selectedimgV)
              selectedimgV.snp.makeConstraints { (make) in
                  make.width.equalTo(20)
                  make.height.equalTo(6)
                  make.centerX.equalToSuperview()
                  make.bottom.equalToSuperview()
              }
              
              
              self.addSubview(lab)
              lab.snp.makeConstraints { (make) in
                  make.edges.equalToSuperview()
              }
    }
    func didSelectedStatue()  {
        self.selectedimgV.isHidden  = false
        self.lab.font = .pingfangSC(20)
        self.lab.textColor = .Hex("#08080D")
    }
    
    func normalStatue()  {
        self.selectedimgV.isHidden  = true
               self.lab.font = .pingfangSC(17)
               self.lab.textColor = .Hex("#FF87827D")
    }
}
//


class SDSScrollTitlesView: UIView {
    var titles:[String] = [String]() {
        didSet{
            self.collectionV.reloadData()
            self.perform(block: {[weak self] in
                self!.scollToIndex(index: 0)
            }, timel: 0.3)
        }
    }
    var rowPadding:CGFloat = .zero {
        didSet{
          let lay =  collectionV.collectionViewLayout as! UICollectionViewFlowLayout
            lay.minimumLineSpacing = rowPadding
        }
    }
    private  var didSelectBlock:((Int,titleCollectCell)->Void)!
    
    private var celectedCell:titleCollectCell?
     var collectionV:UICollectionView!
//        = {
//
////        collect.register(titleCollectCell.self, forCellWithReuseIdentifier: "sdsScorllTitlesView")
//        return collect
//    }()
    func  setLayout() -> UICollectionViewFlowLayout {
        let lay = UICollectionViewFlowLayout()
        lay.scrollDirection = .horizontal
        lay.itemSize = CGSize(width: titleWidth, height: titleHeiht)
//        let totalW:CGFloat = Configs.Dimensions.screenWidth - CGFloat(titles.count) * titleWidth
        lay.minimumInteritemSpacing =  0    //totalW /  CGFloat((titles.count + 1))
        lay.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        lay.minimumLineSpacing = 10
       return lay
    }
    private var cellReuseStr:String!
    var titleWidth:CGFloat = 0
    var titleHeiht:CGFloat = 0
    init(ttles:[String],width:CGFloat,height:CGFloat = 1,cell:AnyClass = titleCollectCell.self ,didSelectBlock:@escaping (Int,titleCollectCell)->Void){
      super.init(frame: .zero)
        self.titles = ttles
             self.didSelectBlock = didSelectBlock
             self.titleWidth = width
             self.titleHeiht = height
        
        self.backgroundColor = .white
         let collect = UICollectionView.init(frame: .zero, collectionViewLayout: setLayout())
         collect.showsVerticalScrollIndicator = false
         collect.showsHorizontalScrollIndicator = false
         collect.backgroundColor = .white
         collect.delegate = self
         collect.dataSource = self
        cellReuseStr = NSStringFromClass(cell)
        collect.register(cell, forCellWithReuseIdentifier: NSStringFromClass(cell))
        collectionV = collect
     
       
       
//        collectionV.delegate = self
//        collectionV.dataSource = self
        self.addSubview(collectionV)
        collectionV.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.perform(block: {[weak self] in
            self!.scollToIndex(index: 0)
        }, timel: 0.3)
    }
    var selectedIndex:Int = 0
   @objc func scollToIndex(index:Int) {
    if index < 0 || index > titles.count - 1 {
        return
    }
    selectedIndex = index
////        if self.celectedCell != nil {
////            self.celectedCell!.normalStatue()
////        }
//        let cell = collectionV.cellForItem(at: IndexPath(row: index, section: 0)) as? titleCollectCell
////        if cell == nil {//
////            self.perform(#selector(scollToIndex(index:)), with: index, afterDelay: 0.35)
////            return
////        }
////        if cell != nil {
////            cell!.didSelectedStatue()
////                  self.celectedCell = cell!
////        }
    collectionV.reloadData()
        collectionV.scrollToItem(at: IndexPath.init(row: index, section: 0), at: .centeredHorizontally, animated: true)
    }

    override func layoutSubviews() {
    let  lay =     collectionV.collectionViewLayout as! UICollectionViewFlowLayout
        if self.sdsH > 0 {
            lay.itemSize = CGSize(width: self.titleWidth, height: self.sdsH)
        }
       
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension SDSScrollTitlesView:UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.titles.count
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        return CGSize(width: 10, height: 10)
//    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseStr, for: indexPath) as! titleCollectCell
      
        cell.settitle(title: titles[indexPath.row])
        cell.normalStatue()
        if indexPath.row == selectedIndex {
            cell.didSelectedStatue()
        }
//        else{
//            cell.normalStatue()
//        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        self.didSelectBlock(indexPath.row,cell! as! titleCollectCell)
        self.scollToIndex(index: indexPath.row)
    }
    
}
