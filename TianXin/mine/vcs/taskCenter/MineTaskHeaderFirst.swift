//
//  MineTaskHeaderFirst.swift
//  TianXin
//
//  Created by SDS on 2020/10/10.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MineTaskHeaderFirst: UITableViewHeaderFooterView {
    var titleArr:[String] = [String]()
    var checkDayNum:Int = 0
    @IBOutlet weak var firstkcoinL: UILabel!
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var yuanL: UILabel!
    @IBOutlet weak var kCoinL: UILabel!
    @IBOutlet weak var activityDetailBut: SDSButton!
    @IBOutlet weak var checkDayLab: UILabel!
    @IBOutlet weak var CheckInBut: UIButton!
    
    @IBOutlet weak var butsV: UIView!
    @IBOutlet weak var adImgV: UIImageView!
    
    
    lazy var vm:TaskFirstHeadViewModel = {
        return TaskFirstHeadViewModel()
    }()
    override func awakeFromNib() {
        super.awakeFromNib()
   
        //
//        self.CheckInBut.setTitle("", for: .normal)
        self.butsV.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        
        
        self.CheckInBut.setBackgroundImage(UIImage.createImgWithColor(color: .Hex("#FFF1F1F1")), for: .normal)
//        self.CheckInBut.setTitle("", for: .selected)
        self.CheckInBut.setBackgroundImage(mainYellowGradienImg, for: .selected)
        activityDetailBut.cornor(conorType: UIRectCorner.init(arrayLiteral: .bottomLeft,.bottomRight), reduis: 5)
        adImgV.isUserInteractionEnabled = true
        adImgV.rx.tapGesture().when(.ended).subscribe(onNext:{ _ in
            //
        }).disposed(by: rx.disposeBag)
     
        
        //
        let refresh = Observable.just(())
        let input = TaskFirstHeadViewModel.Input(
            getData: refresh,
            checkIn: CheckInBut.rx.tap.asObservable()
        )
        let output = vm.transform(input: input)
//        output.model.drive
        output.model.drive(onNext: {[weak self] (mdel) in
            self?.titleL.text = mdel.title
            self?.firstkcoinL.text = "\(mdel.kcoin)"
            self?.kCoinL.text = "您的K币已有\(mdel.kcoin)个，继续努力呢~"
            self?.yuanL.text = "=\(mdel.yuan)元"
            self?.checkDayLab.text = "\(mdel.signCount)/\(mdel.allCount)天"
            self?.CheckInBut.isSelected = !mdel.todayIsSign
            self?.CheckInBut.isEnabled = !mdel.todayIsSign
            for i in 1...mdel.allCount {
                self!.titleArr.append("\(i)天")
            }
            self?.checkDayNum = mdel.signCount
            self?.collectionView.reloadData()
            self?.perform(block: {[weak self] in
                self?.collectionView.scrollToItem(at: IndexPath(row: self!.checkDayNum - (mdel.todayIsSign ? 1 : 0) , section: 0), at: .left, animated: true)
            }, timel: 0.5)
        }).disposed(by: rx.disposeBag)


    }
    lazy var collectionView:UICollectionView = {
        let lay = UICollectionViewFlowLayout()
        lay.minimumLineSpacing = 6
        lay.itemSize = CGSize(width: 41.5, height: 69.5)
        lay.sectionInset =  UIEdgeInsets(top: 0, left: 15.5, bottom: 0, right: 15.5)
    
        lay.scrollDirection = .horizontal
        let collectv = UICollectionView.init(frame: .zero, collectionViewLayout: lay)
        collectv.register(taskHeadFirstCollectCell.self, forCellWithReuseIdentifier: taskHeadFirstCollectCell.className())
        collectv.delegate = self
        collectv.dataSource = self
        collectv.backgroundColor = .white
        collectv.showsHorizontalScrollIndicator = false
        return collectv
    }()
    @IBAction func CheckInButClick(_ sender: UIButton) {
    }
    @IBAction func activityDetailClick(_ sender: SDSButton) {
    }
    
    
}

extension MineTaskHeaderFirst:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        titleArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: taskHeadFirstCollectCell.className(), for: indexPath) as! taskHeadFirstCollectCell
        let isCheck:Bool = indexPath.row < checkDayNum
        cell.set(title: titleArr[indexPath.row], isCheck: isCheck)
        return cell
    }
    
    
}

class  taskHeadFirstCollectCell: UICollectionViewCell {
    lazy var showBut:UIButton = {
        let normalImg = UIImage.createImgWithColor(color: .Hex("FFEEBE"))
        let selectImg  = UIImage.createImgWithColor(color: .Hex("#FFF5F5F5"))
        let but = UIButton.createButWith(title: "1天", titleColor: mainYellowColor, font: .pingfangSC(10), image: #imageLiteral(resourceName: "icon_coin2"), backGroudImg: normalImg) { (but) in
            
        }
        but.setTitleColor(.Hex("#FFBFBFBF"), for: .selected)
        but.setBackgroundImage(selectImg, for: .selected)
        but.setImage(#imageLiteral(resourceName: "icon_coin1"), for: .selected)
//        but.isEnabled = false
        but.isUserInteractionEnabled = false
        but.setButType(type: .imgTop, padding: 7)
        but.cornerRadius = 4
        return but
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(showBut)
        showBut.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    func set(title:String,isCheck:Bool)  {
        self.showBut.setTitle(title, for: .normal)
        self.showBut.isSelected = isCheck
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
