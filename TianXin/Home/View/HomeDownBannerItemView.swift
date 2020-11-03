//
//  HomeDownBannerItemView.swift
//  TianXin
//
//  Created by SDS on 2020/9/22.
//  Copyright © 2020 SDS. All rights reserved.
//


import UIKit

class HomeAtferBanerItmeCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    lazy var imgV:UIImageView = {
      let imgv =  UIImageView()
        imgv.contentMode = .scaleAspectFill
        imgv.image = UIImage(named: "game3")
        imgv.cornor(conorType: .allCorners, reduis: 5)
        return imgv
        
    }()
 
    lazy var textLab:UILabel = {
        let lab = UILabel.createLabWith(title: "体育", titleColor: .black,  font: .pingfangSC(14),aligment: .center)
        return lab
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func  setUI() {
        self.addSubview(imgV)
        imgV.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 50, height: 50))
            make.left.top.equalToSuperview()
        }
        self.addSubview(textLab)
        textLab.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(imgV.snp.bottom).offset(5)
        }
    }
    func setImg(img:UIImage,name:String){
        imgV.image = img
        textLab.text = name
    }
}


class HomeDownBannerItemView: UIView {
    var titles = ["体育","棋牌","真人","电竞","彩票","捕鱼"]{
        didSet{
            self.collectV.reloadData()
        }
    }
    let  imgs:[UIImage] = [#imageLiteral(resourceName: "icon_tiyu"),#imageLiteral(resourceName: "icon_qipai"),#imageLiteral(resourceName: "icon_zhenren"),#imageLiteral(resourceName: "icon_dianjing"),#imageLiteral(resourceName: "icon_caipiao"),#imageLiteral(resourceName: "icon_buyu ")]
    lazy var collectV:UICollectionView = {
//        var dataNum:Int = 6 {
//            didSet{
//                self.collectV.reloadData()
//            }
//        }
        let collectv = UICollectionView.init(frame: .zero, collectionViewLayout: setlayout())
        collectv.delegate = self
        collectv.dataSource = self
        collectv.showsHorizontalScrollIndicator =  false
        collectv.showsVerticalScrollIndicator = false
        collectv.register(HomeAtferBanerItmeCell.self, forCellWithReuseIdentifier: HomeAtferBanerItmeCell.className())
        collectv.backgroundColor = .white
        collectv.isScrollEnabled = false
        return collectv
        
    }()
    func  setlayout() -> UICollectionViewFlowLayout {
        let lay = UICollectionViewFlowLayout()
        lay.itemSize = CGSize(width: scaleX(50), height: scaleX(72))
        lay.scrollDirection = .horizontal
        lay.minimumInteritemSpacing = scaleX(10)
        lay.minimumLineSpacing = scaleX(10)
        lay.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return lay
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(collectV)
        collectV.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension HomeDownBannerItemView:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeAtferBanerItmeCell.className(), for: indexPath) as! HomeAtferBanerItmeCell
        cell.setImg(img: imgs[indexPath.row], name: titles[indexPath.row])
        return cell
    }
    
    
}

