//
//  AboutUS.swift
//  TianXin
//
//  Created by SDS on 2020/9/28.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class AboutUS: SDSBaseVC {
    let titles:[String] = ["版本信息","官方交流群","更新检查"]
    let datails:[String] = ["1.0.0.0","",""]
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "关于我们"
        //
        let logoV = UIImageView(image: UIImage(named: "logo_1"))
        self.view.addSubview(logoV)
        self.view.addSubview(banbenL)
        self.view.addSubview(tableView)
        logoV.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(50 + KnavHeight)
            make.size.equalTo(CGSize(width: 86, height: 86))
        }
        
        banbenL.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoV.snp.bottom).offset(13.5)
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(banbenL.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(44*3)
        }
    }
    lazy var banbenL:UILabel = {
        let lab  = UILabel.createLabWith(title: "甜杏1.0.0.0", titleColor: .Hex("#FF3B372B"), font: .pingfangSC(18))
        return lab
    }()
    lazy var tableView:SDSTableView = {
        let tab = SDSTableView.CreateTableView().sdsNumOfRows(block: { (_) -> Int in
            return 3
        }).sdsRegisterCell(cellClass: AboutTableCell.className(), cellBlock: {[weak self] (indepath, cell) in
        let ncell = cell as! AboutTableCell
            ncell.setTitle(title: self?.titles[indepath.row] ?? "", detail: self?.datails[indepath.row] ?? "")
        }, height: { (_) -> CGFloat in
            return 44
        }).sdsDidSelectCell { (indexPath) in
            
        }
        tab.isScrollEnabled = false
        return tab
    }()

}






class AboutTableCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.backgroundColor = .white
        setUI()
    }
    func setUI(){
        self.contentView.addSubview(titleL)
        self.contentView.addSubview(detailL)
        titleL.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
        }
        detailL.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
        }
    }
    lazy   var titleL:UILabel = {
        let lab = UILabel.createLabWith(title: "", titleColor: .Hex("#FF3B372B"), font: .pingfangSC(15))
            return lab
    }()
    lazy var detailL:UILabel = {
        let lab = UILabel.createLabWith(title: "", titleColor: .Hex("#FF9B9B9B"), font: .pingfangSC(12))
        return lab
    }()
    
    func setTitle(title:String,detail:String) {
        titleL.text = title
        detailL.text = detail
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
