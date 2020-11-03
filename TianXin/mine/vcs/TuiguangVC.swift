//
//  TuiguangVC.swift
//  TianXin
//
//  Created by SDS on 2020/10/1.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class TuiguangVC: SDSBaseVC {
    var invisters:[inviterItem] = [inviterItem]()
    var qrCodeImg:UIImage!
    var  qrString:String = "www.baidu.com"{
        didSet{
            qrimageV.image = SDSQRCode.createQRCode(qrStr: qrString, qrimgBame: nil, downTitle: "kok.com.cn")
        }
    }
    var qrimageV:UIImageView!
    var yaoqingBut:UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "推广中心"
        setUI()
        requist()
    }
    func requist() {
        let vm = TuiGuangViewModel()
        vm.requistMyPromote {[weak self] (model) in
            self!.qrString = model.userInfo.promotUrl
            self!.yaoqingBut.setTitle("已邀请\(model.userInfo.extensionCount)人", for: .normal)
            self?.invisters.removeAll()
            let invister = inviterItem()
            invister.phone = "手机号"
            invister.nickName = "昵称"
            invister.createTime = "创建时间"
            self?.invisters.append(invister)
            self?.invisters.append(contentsOf: model.inviter)
            self?.tableview.reloadData()
        }
    }
    func  setUI(){
        let scrollv  = UIScrollView()
        scrollv.isScrollEnabled = true
      
        self.view.addSubview(scrollv)
       
        let bigimg = UIImage(named: "bg_yuandian")
        let bigbgimgv = UIImageView(image: bigimg)
        bigbgimgv.contentMode = .scaleAspectFill
        scrollv.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(KnavHeight)
            make.height.equalTo(scaleX((bigimg?.size.height)!))
               }
        scrollv.addSubview(bigbgimgv)
//
//
        bigbgimgv.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
                   make.top.equalToSuperview()
            make.size.equalTo(CGSize(width: scaleX(bigimg!.size.width), height: scaleX(bigimg!.size.height)))
               }
        scrollv.contentSize = CGSize(width: Configs.Dimensions.screenWidth, height: KScreenH*2.5)
        let  bgimgv = UIImageView(image: UIImage(named: "tuiguang_bg"))
        bgimgv.contentMode = .scaleAspectFill
        scrollv.addSubview(bgimgv)
        bgimgv.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.size.equalTo(CGSize(width: scaleX(bgimgv.image!.size.width), height: scaleX(bgimgv.image!.size.height)))
        }
        
        let yaoqingBut = UIButton.createButWith(title: "已邀请0人", font: .pingfangSC(18), backGroudImg: UIImage(named: "button_yaoqing"))
        self.yaoqingBut = yaoqingBut
        yaoqingBut.isEnabled = false
        
        scrollv.addSubview(yaoqingBut)
        yaoqingBut.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(scaleX(200))
            make.size.equalTo(CGSize(width: 210.5, height: 51.5))
            
        }
        //
        let girsimgv = UIImageView(image: UIImage(named: "girls"))
        scrollv.addSubview(girsimgv)
        girsimgv.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(scaleX(258))
        }
        //
        let saveCodeBut = UIButton.createButWith(image: UIImage(named: "button_baocun")) { (but) in
            self.saveCodeClick()
        }
        scrollv.addSubview(saveCodeBut)
        saveCodeBut.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(scaleX(520))
//            make.centerX.equalToSuperview()
            make.right.equalTo(self.view).offset(-40)
        }
        //
        let saveUrlBut = UIButton.createButWith(image: UIImage(named: "button_fenxiang")) { (but) in
            self.saveUrlClick()
        }
        scrollv.addSubview(saveUrlBut)
        saveUrlBut.snp.makeConstraints { (make) in
            make.right.equalTo(saveCodeBut)
            make.top.equalTo(saveCodeBut.snp.bottom).offset(15)
        }
        let qrImg =  SDSQRCode.createQRCode(qrStr: qrString,downTitle: "邀请码:kok.com")
        qrCodeImg = qrImg
        let qrimgv = UIImageView(image: qrImg)
        self.qrimageV = qrimgv
        scrollv.addSubview(qrimgv)
        qrimgv.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(scaleX(525.5))
            make.left.equalToSuperview().offset(25)
//            make.size.equalTo(CGSize(width: 87.5, height: 87.5))
        }
        //
        let xiajiLab = UILabel.createLabWith(title: "我的下级", titleColor: .Hex("#FF340439"), font: .pingfangSC(20))
        scrollv.addSubview(xiajiLab)
        xiajiLab.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(saveUrlBut.snp.bottom).offset(30)
        }
        let image = UIImage.CreateGradienImg(colors: [.Hex("#FFFD9076"),.Hex("#FFF95741")])
        let imgv1 = UIImageView.init(image: image)
        let imgv2 = UIImageView.init(image: image)
        let imgv3 = UIImageView.init(image: image)
        let imgv4 = UIImageView.init(image: image)
        scrollv.addSubview(imgv1)
        scrollv.addSubview(imgv2)
        scrollv.addSubview(imgv3)
        scrollv.addSubview(imgv4)
        imgv1.snp.makeConstraints { (make) in
            make.centerY.equalTo(xiajiLab)
            make.right.equalTo(xiajiLab.snp.left).offset(-23.5)
            make.size.equalTo(CGSize(width: 5, height: 5))
        }
        imgv2.snp.makeConstraints { (make) in
                 make.centerY.equalTo(xiajiLab)
                 make.right.equalTo(xiajiLab.snp.left).offset(-11)
                 make.size.equalTo(CGSize(width: 7, height: 7))
             }
        imgv3.snp.makeConstraints { (make) in
                 make.centerY.equalTo(xiajiLab)
                 make.left.equalTo(xiajiLab.snp.right).offset(11)
                 make.size.equalTo(CGSize(width: 7, height: 7))
             }
        imgv4.snp.makeConstraints { (make) in
                 make.centerY.equalTo(xiajiLab)
            make.left.equalTo(xiajiLab.snp.right).offset(23.5)
                 make.size.equalTo(CGSize(width: 5, height: 5))
             }
        scrollv.addSubview(tableview)
        tableview.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(xiajiLab.snp.bottom).offset(19)
            make.size.equalTo(CGSize(width: 340.5, height: 301))
            
        }
    }
    lazy var tableview:SDSTableView = {
        let table = SDSTableView.CreateTableView().sdsNumOfRows(block: {[weak self] (_) -> Int in
            return self!.invisters.count
        }).sdsRegisterCell(cellClass: tuiGuangtableViewCell.className(), cellBlock: {[weak self] (indexPath, cell) in
            let ncell = cell as! tuiGuangtableViewCell
            
            ncell.setModel((self?.invisters[indexPath.row])!)
            if indexPath.row == 0 {
                ncell.backgroundColor = .Hex("#FFFDCD3F")
            }else{
                 ncell.backgroundColor = .Hex("#FFFFDF99")
            }
        }) { (_) -> CGFloat in
            return 44
        }
        return table
    }()
}

extension TuiguangVC {
    func saveCodeClick()  {
        UIImageWriteToSavedPhotosAlbum(qrCodeImg, self, #selector(saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
    }
   
    func saveUrlClick()  {
      let past =  UIPasteboard.general
        past.string = qrString
    }
    @objc private func saveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
              var showMessage = ""
              if error != nil{
                  showMessage = "保存失败"
               SDSHUD.showError(showMessage)
              }else{
                  showMessage = "保存成功"
               SDSHUD.showSuccess(showMessage)
              }
              
       
          }
}





class tuiGuangtableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }
    lazy var nameL:UILabel = {
        let lab = UILabel.createLabWith(title: "用户名", titleColor: .Hex("#FF56575D"), font: .pingfangSC(15))
        return  lab
    }()
    lazy var photoL:UILabel = {
          let lab = UILabel.createLabWith(title: "手机号", titleColor: .Hex("#FF56575D"), font: .pingfangSC(15))
          return  lab
      }()
    lazy var timeL:UILabel = {
            let lab = UILabel.createLabWith(title: "注册时间", titleColor: .Hex("#FF56575D"), font: .pingfangSC(15))
            return  lab
        }()
    func setUI(){
        self.contentView.addSubview(nameL)
        self.contentView.addSubview(photoL)
        self.contentView.addSubview(timeL)
        nameL.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(100)
        }
        photoL.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(nameL.snp.right)
//            make.centerX.equalToSuperview()
        }
        timeL.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
    }
    
    func setModel(_ model:inviterItem)  {
        nameL.text = model.nickName
        photoL.text = model.phone.count > 0 ? model.phone : "未绑定"
        timeL.text = model.createTime
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
