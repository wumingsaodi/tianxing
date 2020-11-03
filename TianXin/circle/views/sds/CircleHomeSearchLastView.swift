//
//  CircleHomeSearchLastView.swift
//  TianXin
//
//  Created by SDS on 2020/10/31.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
class CircleHomeSearchLastView: UIView {
//    var items = BehaviorRelay<[String]>(value: [])
    lazy var vm:CircleHomeSearchLastViewModel = {
        return CircleHomeSearchLastViewModel()
    }()
    var deleAllDriver = PublishSubject<Void>()
    var deleSingleDriver = PublishSubject<String>()
    var selectedTitle:BehaviorRelay = BehaviorRelay<String>(value: "")
    override init(frame: CGRect) {
        super.init(frame: frame)
        let  tap  = UITapGestureRecognizer.init(target: self, action: #selector(tapClick))
        tap.delegate = self
        self.addGestureRecognizer(tap)
    setUI()

        
    let datasource = RxCollectionViewSectionedReloadDataSource<SectionModel<String,searchItem>> (configureCell: { (dataSource, collectionview, indexpath, item) -> UICollectionViewCell in
        let  cell  = collectionview.dequeueReusableCell(for: indexpath) as CircleHomeSearchCell
        cell.title = item.content
        return cell
    }) { (ds, collectionview, kind, indexPath) -> UICollectionReusableView in
        let header = collectionview.dequeueReusableHeaderView(for: indexPath) as CircleHomeSearchHead
        header.setHeader(title: ds[indexPath.section].model)
        return  header
    }
        
  
        Observable.combineLatest(collectionv.rx.itemSelected, collectionv.rx.modelSelected(searchItem.self)).subscribe(onNext: {[weak self] (indexPath,model) in
            let cell =   self?.collectionv.cellForItem(at: indexPath) as! CircleHomeSearchCell
            if cell.isShake{
                self?.deleSingleDriver.onNext(model.id)
                }else{
                self?.selectedTitle.accept(model.content)
            }
            
        }) .disposed(by: rx.disposeBag)
//        collectionv.rx.itemSelected
//            .asObservable()
//            .subscribe(onNext: { [weak self] indexPath in
//                guard let self = self else{
//                    return
//                }
//                let cell =   self.collectionv.cellForItem(at: indexPath) as! CircleHomeSearchCell
//                if cell.isShake{
//
////                    var value = self.items.value
////                    value.remove(at: indexPath.row)
////                    self.items.accept(value)
//                }else{
//                    self.selectedTitle.accept(self.items.value[indexPath.row])
//                }
//
//            })
           
        //获取数据
        let startDriver = Driver<Void>.just(())
        let input = CircleHomeSearchLastViewModel.Input.init(InStart: startDriver, deleAll: deleAllDriver.asDriverOnErrorJustComplete(), deleSingle: deleSingleDriver.asDriverOnErrorJustComplete())
        let  out =  vm.transform(input: input)
        
        out.searchRecentArr.map({[SectionModel(model: "搜索历史", items: $0)]}).drive(collectionv.rx.items(dataSource: datasource)).disposed(by: rx.disposeBag)
//        let input = CircleHomeSearchLastViewModel.Input.init(InStart: Driver.startWith(self), deleAll: deleAllDriver, deleSingle: deleSingleDriver)
        
}
    @objc func tapClick(){
        NJLog("tap clcik")
        (collectionv.visibleCells as! [CircleHomeSearchCell]).forEach { (cell) in
            cell.isShake = false
            cell.layer.removeAllAnimations()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUI()  {
    self.addSubview(collectionv)
    collectionv.snp.makeConstraints { (make) in
        make.edges.equalToSuperview()
    }
        //
        self.addSubview(delbut)
        delbut.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(15)
        }
}
    lazy var delbut:UIButton = {
        let but = UIButton()
        but.setImage(#imageLiteral(resourceName: "delete"), for: .normal)
        but.rx.tap.subscribe(onNext: {
            self.defualtAlert(title: "提示", message: "你确定要删除最近搜索记录") {[weak self] (_) in
                self?.deleAllDriver.onNext(())
//                self?.deleAllDriver.accept(())
            }
        }).disposed(by: rx.disposeBag)
        return  but
    }()
lazy var  collectionv:UICollectionView = {
    let lay = cireHomeLeftLayout()
    lay.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    lay.itemSize = CGSize(width: 100, height: 30)
    lay.headerReferenceSize = CGSize(width: KScreenW, height: 44)
    let collectionv = UICollectionView.init(frame: .zero, collectionViewLayout: lay)
    collectionv.registerClass(type: CircleHomeSearchCell.self)
    collectionv.registerHeaderClass(type: CircleHomeSearchHead.self)
    collectionv.backgroundColor = .white
    return collectionv
}()

}
extension CircleHomeSearchLastView:UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UICollectionViewCell {
            NJLog("UICollectionViewCell")
            return false
        }
        if gestureRecognizer.view!.isKind(of: UICollectionView.self) {
            return false
        }
        return true
    }
    
}

//MARK: - headClass
class CircleHomeSearchHead: UICollectionReusableView {
override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.addSubview(lab)
    lab.snp.makeConstraints { (make) in
        make.centerY.equalToSuperview()
        make.left.equalToSuperview().offset(15)
    }
    let imgv = UIImageView.init(image: #imageLiteral(resourceName: "icon_button_xuanzhong"))
    self.addSubview(imgv)
    imgv.snp.makeConstraints { (make) in
        make.centerX.equalTo(lab.snp.left).offset(2)
        make.centerY.equalTo(lab.snp.bottom).offset(2)
        }
    
}
required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
}
lazy var lab:UILabel = {
    return UILabel.createLabWith(title: "", titleColor: .Hex("#FF3B372B"), font: .pingfangSC(17))
}()
func setHeader(title:String){
    lab.text = title
}
}

//MARK: - collectionViewCell
class CircleHomeSearchCell: UICollectionViewCell {
var title:String?{
    didSet{
        if self.isShake {
//            NJLog("anim:\(self.layer.animationKeys())")
            let  anim = self.layer.animation(forKey: "circleHomeShake")
            if anim == nil {
                self.layer.add(self.animtion, forKey: "circleHomeShake")
            }
        }
        titleBut.text = title
    }
 
}
    var isShake:Bool = false
lazy var titleBut:UILabel = {
    let but = UILabel()
    but.textAlignment = .center
//    but.isEnabled = false
    but.layer.cornerRadius = 15
    but.borderColor = mainYellowColor
    but.borderWidth = 1
    
    let imgv = UIImageView.init(image: #imageLiteral(resourceName: "icon_chahao"))
    imgv.isHidden = true
    imgv.tag = 101
    but.addSubview(imgv)
    imgv.snp.makeConstraints { (make) in
        make.centerX.equalTo(but.snp.right).offset(-5)
        make.centerY.equalTo(but.snp.top).offset(5)
    }
    return but
}()
override init(frame: CGRect) {
   
    super.init(frame: .zero)
    self.addSubview(titleBut)
    let long = UILongPressGestureRecognizer.init(target: self, action: #selector(longtap))
    self.addGestureRecognizer(long)
    titleBut.snp.makeConstraints { (make) in
        make.edges.equalToSuperview()
    }
 
}
    @objc func longtap(){
        let collectv =     self.superview as! UICollectionView
        NJLog("count -> \(collectv.visibleCells.count) ")
        collectv.visibleCells.forEach { (cell) in
            let ncell = cell as! CircleHomeSearchCell
            ncell.isShake = true
            ncell.titleBut.viewWithTag(101)?.isHidden  = false
            ncell.titleBut.layer.add(animtion, forKey: "circleHomeShake")
        }
    }
    lazy var animtion:CABasicAnimation = {
        return shakeAnimial()
    }()
    func shakeAnimial()->CABasicAnimation{
        let anim = CABasicAnimation(keyPath: "transform.rotation.z")
        anim.fromValue = -0.1
        anim.toValue = 0.1
        anim.duration = 0.2
        anim.repeatCount = HUGE
        anim.autoreverses = true
        anim.isRemovedOnCompletion = false //切出此界面再回来动画不会停止
        return anim
    }
required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
}

}


//MARK: - layoutClass

class cireHomeLeftLayout: UICollectionViewFlowLayout {
var maxY:CGFloat = -1
var leftMargin:CGFloat = 0
override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    let attributesArr = super.layoutAttributesForElements(in: rect)
    maxY = -1
    leftMargin = 0
    attributesArr?.forEach({ (attributes) in
        guard   attributes.representedElementCategory == .cell else{//header footer
            return
        }
        
        
        if attributes.frame.origin.y > maxY {
            leftMargin = sectionInset.left
        }
        attributes.frame.origin.x = leftMargin
        leftMargin += attributes.frame.size.width + minimumInteritemSpacing
        maxY = max(attributes.frame.origin.y, maxY)
    })
    return attributesArr
}
}

