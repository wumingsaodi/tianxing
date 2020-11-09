//
//  mineSettingVC.swift
//  TianXin
//
//  Created by SDS on 2020/9/25.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class mineSettingVC: SDSBaseVC, UINavigationControllerDelegate {
    lazy var vm:UserInfoViewModel = {
        return UserInfoViewModel()
    }()
    let titles = ["图像","昵称","年龄","性别","个性签名"]
    var iconUrL:String?
    var subs = ["","","","",""]
    var selectedImg:UIImage? //= UIImage(named: "defult_user")
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "个人信息"
        self.view.addSubview(tableView)
        tableView.isScrollEnabled = false
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(KnavHeight + 10)
            
        }
//        setNavRightBut()
        LocalUserInfo.share.getLoginInfo {[weak self] (model) in
            guard let model = model else{
                return
            }
//            guard let self = self {
//                return
//            }
            self?.iconUrL = model.userLogo
            self?.subs[1] = model.nickName
            self?.subs[2] = model.age
            self?.subs[3] = model.gender.toChina
            self?.subs[4] = model.userSign
            self?.tableView.reloadData()
        }
    }

//    func  setNavRightBut() {
//        let but = UIButton.createButWith(title: "保存",  font: .pingfangSC(17), backGroudColor: mainYellowColor) {[weak self] (but) in
//            self?.uploadInfo()
//        }
//        but.frame = CGRect(x: 100, y: 100, width: 60, height: 30)
//        but.cornor(conorType: .allCorners, reduis: 10)
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: but)
//    }
    lazy   var tableView:SDSTableView = {
        let tab = SDSTableView.CreateTableView().sdsNumOfRows(block: { (_) -> Int in
            return 5
        }).sdsRegisterCell(cellClass: mineSettingVCCell.className(), cellBlock: { [weak self](indepath, cell) in
            let ncell = cell as! mineSettingVCCell
            if indepath.row == 0 {
                ncell.settitle(title:self!.titles[indepath.row],detail:self!.subs[indepath.row],iconUrl:self?.iconUrL,icon: self?.selectedImg)
            }else{
                ncell.settitle(title:self!.titles[indepath.row],detail:self!.subs[indepath.row],iconUrl:nil)
            }
           
            
            }, height: { (inpath) -> CGFloat in
                if inpath.row == 0 {
                    return 84
                }
                return 44
        }).sdsDidSelectCell {[weak self] (indexPath) in
            if indexPath.row == 0 {//上传图像
                self?.view.addSubview(self!.pickV)
                self!.pickV.set(title: "上传图像", subTitles: ["拍照上传","从手机相册选取"]) { (index,text) in
                   if index == 0 {
                    self!.openCamera()
                    }else{
                    self!.openAblume()
                    }
                }
            }else if indexPath.row == 1 {
                let vc = NickChangeVC()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            else if indexPath.row == 2 {//年龄
                
                self?.view.addSubview(self!.pickV)
                self!.pickV.set(title: "选择年龄", subTitles: self!.ageTitles) { (index,text) in
                    self?.subs[indexPath.row] = text
                    self?.uploadInfo()
//
//                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }else if indexPath.row == 3 {//性别
                self?.view.addSubview(self!.pickV)
                self!.pickV.set(title: "选择性别", subTitles: ["男","女"]) { (index,text) in
                    self?.subs[indexPath.row] = text
                    self?.uploadInfo()
//                    self?.subs[indexPath.row] = text
//                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }else if indexPath.row == 4 {//个性签名
              let  vc = MineSignatureVC()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
        return tab
    }()
    
    lazy var pickV:SDSPickView = {
        let pickv = SDSPickView(title: "上传图像", subTitles: ["拍照上传","从手机相册选取"]) { (index,text) in
            
        }
        self.view.addSubview(pickv)
        return pickv
    }()
    lazy var ageTitles:[String] = {
        var arr = [String]()
        for i in 18...100{
            arr.append("\(i)")
        }
        return arr
    }()
    func openCamera() {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            SDSHUD.showError("不能打开照相机，请前往隐私设置")
            return
        }
        
        let imgPickvc = UIImagePickerController()
        imgPickvc.delegate = self
        imgPickvc.allowsEditing = true
        imgPickvc.sourceType = .camera
        self.present(imgPickvc, animated: true, completion: nil)
        
    }
    func openAblume()  {
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            SDSHUD.showError("不能打开相ce，请前往隐私设置")
            return
        }
        let imgpickvc = UIImagePickerController()
        imgpickvc.delegate = self
        imgpickvc.sourceType = .photoLibrary
        imgpickvc.allowsEditing = true
        self.present(imgpickvc, animated: true, completion: nil)
    }
}


extension mineSettingVC:UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
          let editImg  =   info[.editedImage]
        self.selectedImg = (editImg as! UIImage)
//        NetWorkingHelper.uploadImage(images:  self.selectedImg!) { (dict) in
            vm.uploadUserInfo(img: selectedImg)
//        }
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        picker.dismiss(animated: true, completion: nil)
    }
}






class mineSettingVCCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .white
        setUI()
    }
    var titleL:UILabel!
    var detailL:UILabel!
    lazy var iconimgV:UIImageView = {
        let imgv = UIImageView()
        imgv.sdsSize = CGSize(width: 62, height: 62)
        imgv.cornor(conorType: .allCorners, reduis: 31)
        return imgv
        
    }()
    func  setUI(){
        titleL = UILabel.createLabWith(title: "", titleColor: .Hex("#FF87827D"), font: .pingfangSC(15))
        self.contentView.addSubview(titleL)
        detailL = UILabel.createLabWith(title: "", titleColor: .Hex("#FF87827D"), font: .pingfangSC(15))
        self.contentView.addSubview(detailL)
        let moreimgv = UIImageView(image: UIImage(named: "Back_more"))
        self.contentView.addSubview(moreimgv)
        self.contentView.addSubview(iconimgV)
        titleL.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
        }
        moreimgv.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
        }
        detailL.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(moreimgv.snp.left).offset(-10)
        }
        iconimgV.isHidden = true
        iconimgV.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(moreimgv.snp.left).offset(-10)
            make.size.equalTo(iconimgV.sdsSize)
        }
        
    }
    func settitle(title:String,detail:String?,iconUrl:String? = nil,icon:UIImage? = nil){
        titleL.text = title
        detailL.text = detail
        detailL.isHidden = false
        iconimgV.isHidden = true
        if icon != nil {
            iconimgV.image = icon
            detailL.isHidden = true
            iconimgV.isHidden = false
        }
        if iconUrl != nil {
//            if icon != nil {
                iconimgV.loadUrl(urlStr: iconUrl!, placeholder:"")
//            }
            
            detailL.isHidden = true
            iconimgV.isHidden = false
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - actons
extension mineSettingVC {
    func uploadInfo(){
        var genderStr = "0"
        if subs[3] == "女" {
            genderStr = "1"
        }
        vm.uploadUserInfo(age: subs[2], gender: genderStr)
    }
}
