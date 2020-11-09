//
//  SettingVC.swift
//  TianXin
//
//  Created by SDS on 2020/9/25.
//  Copyright © 2020 SDS. All rights reserved.
//
import UIKit
import Kingfisher
class SettingVC: SDSBaseVC {
    var totalCacheStr:String = "0M"
    var isPhotobanded:Bool = false
    var isEmailbinded:Bool = false
    var isPassWordSeted:Bool = true
    let headerTitls:[String] = ["账号安全","其他"]
    var userInfo:UserInfoModel?
    var code = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "系统设置"
        self.view.addSubview(tableView)
        self.view.addSubview(outLoginBut)
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(443)
        }
        outLoginBut.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(tableView.snp.bottom).offset(40)
            make.size.equalTo(CGSize(width: 205, height: 38))
          
        }
        LocalUserInfo.share.getLoginInfo {[weak self] (model) in
            self?.userInfo = model
            if let info  = model {
                self?.isPhotobanded  = info.phone.count > 0
                self?.isEmailbinded = info.email.count > 0
            }
           
            self?.tableView.reloadData()
        }
      _ =  getAllCacheSize()
    }
    lazy var outLoginBut:UIButton = {
        let img = UIImage.CreateGradienImg(colors: [.Hex("#FFFFD26B"),.Hex("#FFF8944B")])
        let but = UIButton.createButWith(title: "退出登录", titleColor: .white, font: .pingfangSC(15),backGroudImg:img ) {[weak self] (_) in
            LoginViewModel.share.requestLogout {
                self?.perform(block: {
                    self?.navigationController?.popToRootViewController(animated: true)
                }, timel: 0.5)
            }
            //退出登陆
        }
        
        but.cornor(conorType: .allCorners, reduis: 19)
        return but
    }()
    lazy var tableView:SDSTableView = {
        let table = SDSTableView.CreateTableView().sdsNumOfSections(block: {
            return 2
        }).sdsNumOfRows(block: { (section) -> Int in
//            if section == 0 {
//                return 1
//            }else
            if section == 0 {
                return 4
            }
            return 2
            
        }).sdsRegisterCell(cellClass: SettingTableCell.className(), cellBlock: { (indepath, cell) in
            let ncell = cell as! SettingTableCell
//            if  indepath.section == 0 {
//                ncell.set(title: "语言设置", detail: "简体中文",lineHide: true)
//            }
              if  indepath.section == 0 {
                if indepath.row == 0 {
                    let name =   self.userInfo?.userName ?? ""
                    ncell.set(title: "我的账号", detail: name,backimgHide: true)
                }else  if indepath.row == 1 {
                    let phone = LocalUserInfo.share.showPhoto.count > 0 ? LocalUserInfo.share.showPhoto  :"未绑定"
                    ncell.set(title: "手机号", detail: phone)
                }
                else  if indepath.row == 2 {
                    let email =  LocalUserInfo.share.showEmail.count > 0 ? LocalUserInfo.share.showEmail :"未绑定"
                    ncell.set(title: "邮箱", detail: email,backimgHide: false)
                }
                else  if indepath.row == 3 {
                    ncell.set(title: "修改密码", detail: "",lineHide: true)
                }
            }
            else  if  indepath.section == 1 {
                if indepath.row == 0 {
                    
                    ncell.set(title: "清除缓存", detail: self.totalCacheStr)
                }
                if indepath.row == 1 {
                    let version =    Bundle.main.infoDictionary!["CFBundleShortVersionString"]
                       
                    ncell.set(title: "版本号", detail: "v \(version!)")
                }
            }
        }, height: { (indexpath) -> CGFloat in
            return 44
        }).sdsRegisterHeader(headerClass: simpleTextHeader.className(), headerBlock: { (section, header) in
            let nheader = header as! simpleTextHeader
            nheader.setTitle(title: self.headerTitls[section])
        }, height: { (section) -> CGFloat in
//            if section == 0{
//                return 0.1
//            }
            return 44
        }).sdsDidSelectCell { (indexPath) in
            if indexPath.section == 0 {
                if indexPath.row == 1 {//手机号
                    if self.isPhotobanded {
                        let vc = selectedPhotoOrEmail()
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else{
                        let vc = PhotoNumerVC.init(nibName: "PhotoNumerVC", bundle: nil)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    
                }else if indexPath.row == 2 {//邮箱
                    var vc:UIViewController!
                    if self.isEmailbinded {
                        vc = selectedPhotoOrEmail()
                        (vc as! selectedPhotoOrEmail) .type = .email
                        
                    }else{
                        vc = PhotoNumerVC.init(nibName: "PhotoNumerVC", bundle: nil)
                        (vc as! PhotoNumerVC) .type = .email
                    }
                    
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }else if indexPath.row == 3 {//密码
                    var vc:UIViewController!
                    if self.isPassWordSeted {
                        vc =  PassWordChangeVC()
                        
                    }else{
//                        vc = PasswordSettingVC(code: self.code)
                    }
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }else if indexPath.section == 1 {
                if indexPath.row == 0 {
                    self.defualtAlert(title: "提示", message: "您确认要删除缓存", sureBlock: {[weak self] (_) in
                        self?.clearAllCache()
                    })
                }
            }
        
        }
        return table
    }()
}




//header
class simpleTextHeader: UITableViewHeaderFooterView {
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = baseVCBackGroudColor_grayWhite
        self.contentView.addSubview(textL)
        textL.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
        }
    }
    lazy var textL:UILabel = {
        let lab = UILabel.createLabWith(title: "", titleColor: .Hex("#FF3B372B"), font: .pingfangSC(17))
        return lab
    }()
    func  setTitle(title:String){
        textL.text = title
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//cell
class SettingTableCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .white
        setUI()
    }
    func setUI() {
        self.contentView.addSubview(titleL)
        self.contentView.addSubview(detailL)
        self.contentView.addSubview(moreimgv)
        self.contentView.addSubview(line)
        //
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
            make.right.equalTo(moreimgv.snp.left).offset(-20)
        }
        line.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    func set(title:String,detail:String,backimgHide:Bool = false,lineHide:Bool = false) {
        self.titleL.text = title
        self.detailL.text = detail
        //        if backimgHide {
        //            self.detailL.snp.updateConstraints { (make) in
        //                make.right.equalToSuperview().offset(-20)
        //            }
        //        }else{
        //            self.detailL.snp.updateConstraints { (make) in
        //                make.right.equalTo(moreimgv.snp.left).offset(-20)
        //                      }
        //        }
        line.isHidden = false
        if lineHide {
            line.isHidden = true
        }
    }
    lazy var detailL:UILabel  = {
        let lab = UILabel.createLabWith(title: "", titleColor: .Hex("#FF87827D"), font: .pingfangSC(15))
        return lab
    }()
    
    lazy  var moreimgv:UIImageView = {
        let imgv = UIImageView(image: UIImage(named: "Back_more"))
        return imgv
    }()
    lazy var titleL:UILabel  = {
        let lab = UILabel.createLabWith(title: "", titleColor: .Hex("#FF87827D"), font: .pingfangSC(15))
        return lab
    }()
    lazy  var line :UIView = {
        let view = UIView()
        view.backgroundColor = baseVCBackGroudColor_grayWhite
        return view
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//MARK: - 缓存数据
extension SettingVC {
    func clearAllCache(){
        SDSHUD.showloading()
        clearCache(path: NSTemporaryDirectory())
        //
        let libraryCachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last
        clearCache(path: libraryCachePath!)
        ImageCache.default.clearCache {[weak self] in
          _ =  self?.getAllCacheSize()
            SDSHUD.showSuccess("缓存清除成功")
        }
        
    }
    func clearCache(path:String){
      let  subPathArra =  try? FileManager.default.contentsOfDirectory(atPath: path)
        guard let subPathArr = subPathArra else {
            return
        }
        for subPath in subPathArr {
            let filepath =  path.appending(subPath)
           try?   FileManager.default.removeItem(atPath: filepath)
        }
    }
    func getAllCacheSize() -> String{
        var totalSize:UInt = 0
        let temp = NSTemporaryDirectory()
       let tempSize =   getCaches(path: temp)
        totalSize += tempSize
        let libraryCachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last
        let libraCacheSize = getCaches(path: libraryCachePath!)
        totalSize += libraCacheSize
        
        Kingfisher.ImageCache.default.calculateDiskStorageSize {[weak self] (res) in
            switch res{
            case .success( let size):
                totalSize += size
                self?.totalCacheStr = (self?.cacheIntToString(cache: totalSize))!
                self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
            case .failure(_):
                self?.totalCacheStr = (self?.cacheIntToString(cache: totalSize))!
                self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .automatic)
                break
            }
        }
        return ""
    }
    func cacheIntToString(cache:UInt) -> String {
        var str = "0M"
        if cache > 1024*1024*1024 {
            str = String(format: "%0.2fG",Double(cache) / Double(1024*1024*1024))
        }
        else if cache > 1024*1024 {
            str = String(format: "%0.2fM",Double(cache) / Double(1024*1024))
        }
        else if cache > 1024{
            str = String(format: "%0.2fKB",Double(cache) / Double(1024))
        }else {
            str = String(format: "%0.2fB",Double(cache))
        }
        return str
    }
    func getCaches(path:String) -> UInt {
        var totalSize:UInt = 0
//        FileManager.d
        let subPathArr = FileManager.default.subpaths(atPath: path)
        if subPathArr != nil {
            for subPath in subPathArr! {
                let filePath = path.appending(subPath)
                var isDir = ObjCBool.init(false)
              let isExist =   FileManager.default.fileExists(atPath: filePath, isDirectory: &isDir)
                if !isExist || isDir.boolValue || filePath.contains(".DS") {
                    continue
                }
                let size = try? FileManager.default.attributesOfItem(atPath: filePath)[FileAttributeKey.size] as? UInt
                totalSize += size ?? 0
                
            }
            return totalSize
           
        }else{
          // return 0
        }
        return 0
    }
}
