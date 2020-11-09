//
//  HomeDetailVC.swift
//  TianXin
//
//  Created by SDS on 2020/9/25.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class HomeDetailVC: UIViewController {
    let leftRightMargin:CGFloat = 10
    var model:HomedetailModel = HomedetailModel() {
        didSet{
           coverImgUrl = model.movie.pic
           url = model.movie.url
            self.dataModels = model.guess
            leftBut.setTitle(model.movie.name, for: .normal)
        }
    }
    var dataModels:[HomeItemModel] = [HomeItemModel](){
        didSet{
            if dataModels.count > 0 {
                self.collectionView.reloadData()
            }
        }
    }
    var id:String = ""
    var coverImgUrl:String = "" {
        didSet {
            self.playerVC.coverImgUrl = coverImgUrl
        }
    }
    var url:String = ""  {
        didSet{
            if  let playUrl  = URL(string: url) {
                playerVC.url = playUrl
            }
           
        }
    }  //"https://media.w3.org/2010/05/sintel/trailer.mp4"
    lazy   var playerVC:SDSPlayerVC = {
    let play =   SDSPlayerVC.init(url: url, coverImgUrl:self.coverImgUrl )
        play.isCanBeiginPlay = true
        play.fullScreenBlock = {[weak self](isFull) in
            self?.leftBut.isHidden = isFull
        }
        return play
    }()
    private lazy var leftBut:UIButton = {
      let    but = UIButton.createButWith(title: "ppsds", titleColor:.white, font: .pingfangSC(17), image: UIImage(named: "back_white")) {[weak self] (_) in
            self?.navigationController?.popViewController(animated: true)
        }
        but.setButType(type: .imgLeft, padding: 8)
        return but
    }()
    let vm = HomeDetailViewMoodel()
    func setNav(){
        self.navigationController?.navigationBar.isHidden = true
        if sdsKeyWindow == nil {
            return
        }
        sdsKeyWindow?.addSubview(leftBut)
        leftBut.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(kStatueH)
            make.width.lessThanOrEqualTo(250)
        }
    }
    convenience init(coverUrl:String,id:String) {
          self.init()
        self.coverImgUrl = coverUrl
        self.id = id
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNav()
    }
    override func viewWillDisappear(_ animated: Bool) {
        leftBut.removeFromSuperview()
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        if kAppdelegate.islogin() == false {
                 return
             }
        
        setUI()
//        vm.requistMovieDetail(id: id){[weak self](model) in
//            self!.coverImgUrl = model.movie.pic
//            self?.url = model.movie.url
//
//        }
    }
    
    func  setUI() {
       //视频播放器
        self.addChild(playerVC)
        self.view .addSubview(playerVC.view)
        playerVC.view.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(240)
        }

        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(playerVC.view.snp_bottomMargin).offset(5)
            make.bottom.equalToSuperview()
        }

    }
    
    lazy var collectionView:UICollectionView = {
        let lay = UICollectionViewFlowLayout()
        let width = (Configs.Dimensions.screenWidth - leftRightMargin*2 - 30) / 2
        lay.itemSize = CGSize(width: width, height: 165)
        lay.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        lay.minimumLineSpacing = 0
        lay.minimumInteritemSpacing = 10
        lay.headerReferenceSize = CGSize(width: Configs.Dimensions.screenWidth, height: HomeDetialTopView.headerH + 35)
        
        let collect = UICollectionView.init(frame: .zero, collectionViewLayout: lay)
        collect.backgroundColor = .white
        collect.register(HomeDetailColletCell.self, forCellWithReuseIdentifier: HomeDetailColletCell.className())
        collect.delegate = self
        collect.dataSource = self
        collect.register(HomeDetailcollectHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeDetailcollectHeader.className())
        return collect
    }()

}
extension HomeDetailVC:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataModels.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeDetailColletCell.className(), for: indexPath) as! HomeDetailColletCell
        cell.setModel(model: dataModels[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeDetailcollectHeader.className(), for: indexPath) as! HomeDetailcollectHeader
        header.setHeadModel(model: model)
        return header
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = dataModels[indexPath.row]
        vm.requistMovieDetail(id: model.id) {[weak self] (model) in
            self!.model = model
        }
    }
}









class HomeDetailcollectHeader: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setUI()
    }
    lazy var topV:HomeDetialTopView = {
        let titles = ["性感美女","人妻","中文字幕","无码"]
        let topV = HomeDetialTopView.init(titles: titles)
        return topV
    }()
    func setUI(){
        self.addSubview(topV)
        let imgv = UIImageView(image: UIImage(named: "icon_button_xuanzhong"))
        self.addSubview(imgv)
        self.addSubview(textLab)
        
        topV.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(HomeDetialTopView.headerH)
        }
        
        imgv.snp.makeConstraints { (make) in
            make.centerX.equalTo(textLab.snp_leftMargin)
            make.centerY.equalTo(textLab.snp_bottomMargin)
        }
        textLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.top.equalTo(topV.snp_bottomMargin).offset(5)
        }
        
    }
  lazy  var textLab:UILabel = {
    let lab = UILabel.createLabWith(title: "相似推荐", titleColor: .Hex("#FF3B372B"),  font: .pingfangSC(17))
    return lab
    }()
    func setHeadModel(model:HomedetailModel)  {
        self.topV.setHeadModel(model: model)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class HomeDetailColletCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.contentView.cornor(conorType: .allCorners, reduis: 5)
        setUI()
    }
    lazy var loveBut:UIButton = {
        let  but = UIButton.createButWith(title: "0", titleColor: .white, font: .pingfangSC(13), image: #imageLiteral(resourceName: "shoucang2")) { (but) in
        
        }
        but.setButType(type: .imgLeft, padding: 5)
        but.setImage(#imageLiteral(resourceName: "icon_dianzan1"), for: .selected)
        return  but
    }()
    lazy var guanKBut:UIButton = {
        let  but = UIButton.createButWith(title: "0", titleColor: .white, font: .pingfangSC(13), image: #imageLiteral(resourceName: "liulanliang")) { (but) in
        
        }
        but.setButType(type: .imgLeft, padding: 5)
        but.isEnabled = false
//        but.setImage(#imageLiteral(resourceName: "icon_dianzan1"), for: .selected)
        return  but
    }()
    lazy var imgv:UIImageView = {
        let imgv = UIImageView()
        imgv.image = UIImage(named: "defualt")
        imgv.contentMode = .scaleAspectFill
        imgv.cornor(conorType: .allCorners, reduis: 8)
        let bgv = UIView()
        bgv.backgroundColor = .Hex("#40000000")
        imgv.addSubview(bgv)
        bgv.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(20)
        }
        bgv.addSubview(loveBut)
        loveBut.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
        }
        bgv.addSubview(guanKBut)
        guanKBut.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
        }
        imgv.isUserInteractionEnabled = true
        return imgv
    }()
    lazy var detailLab:UILabel = {
        let lab = UILabel.createLabWith(title: "直播性感小姐姐正在直播直播中直播中", titleColor: .Hex("#FF3B372B"), font: .pingfangSC(15))
        return lab
    }()
    func setUI(){
        
        self.contentView.addSubview(imgv)
        imgv.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(124.5)
        }
        self.contentView.addSubview(detailLab)
        detailLab.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().offset(5)
            make.top.equalTo(imgv.snp.bottom).offset(5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setModel(model:HomeItemModel){
        loveBut.isSelected = model.isLike
        loveBut.setTitle("\(model.loveNums)", for: .normal)
        guanKBut.setTitle("\(model.historyNum)", for: .normal)
        detailLab.text = model.name
        imgv.loadUrl(urlStr: model.pic, placeholder: UIImage(named: "defualt")!)
    }
}
