//
//  HomeMoretableViewCell.swift
//  TianXin
//
//  Created by SDS on 2020/9/22.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class HomeMoreTableViewHeader: UITableViewHeaderFooterView {
    static let  headerH:CGFloat = 44
    var titleLab:UILabel = {
        let lab = UILabel.createLabWith(title: "专题推荐", titleColor: .Hex("#FF3B372B"), font: .pingfangSC(17))
        return lab
    }()
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .white
        let imgv = UIImageView(image: UIImage(named: "icon_button_xuanzhong"))
        self.contentView.addSubview(imgv)
        self.contentView.addSubview(titleLab)
        imgv.snp.makeConstraints { (make) in
            make.centerX.equalTo(titleLab.snp.left)
            make.centerY.equalTo(titleLab.snp.bottom)
        }
        titleLab.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class HomeMoretableViewCell: UITableViewCell {
    static let cellH:CGFloat = 245
    lazy var imgv:UIImageView = {
        let imgv = UIImageView()
        imgv.contentMode = .scaleToFill
        imgv.image = UIImage(named: "defualt")
        return imgv
    }()
    lazy var titleLab:UILabel = {
        let lab = UILabel.createLabWith(title: "中文字幕", titleColor: .Hex("#3B372B"), font: .pingfangSC(17))
        return lab
    }()
  lazy  var tagBut:UIButton = {
    let but = UIButton.createButWith(title: "1234部", titleColor: .white,font: .pingfangSC(13), image:UIImage.init(named: "icon_viddeo"), backGroudColor: mainYellowColor)
    but.setButType(type: .imgLeft, padding: 3)
    but.sdsSize = CGSize(width: 78, height: 24)
    but.cornor(conorType: .allCorners, reduis: 12)
    but.isUserInteractionEnabled = false
    return but
    }()
    lazy var  detailLab:UILabel = {
        let lab = UILabel.createLabWith(title: "定期为你推荐最美好的撸啊撸素材，永远和你温柔相伴", titleColor: .Hex("#FF969696"), font: .pingfangSC(14))
        lab.numberOfLines = 0
        return lab
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.cornor(conorType: .allCorners, reduis: 8)
        self.contentView.backgroundColor = baseVCBackGroudColor_grayWhite
        setUI()
    }
    
    func setUI(){
        let bgv = UIView()
        bgv.backgroundColor = .white
        self.contentView.addSubview(bgv)
        bgv.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview()
        }
        //
        bgv.addSubview(imgv)
        imgv.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(147)
        }
    //
        bgv.addSubview(tagBut)
        tagBut.snp.makeConstraints { (make) in
            make.size.equalTo(tagBut.sdsSize)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
        }
        //
        bgv.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.top.equalTo(imgv.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(15)
        }
        //
        bgv.addSubview(detailLab)
        detailLab.snp.makeConstraints { (make) in
            make.left.equalTo(titleLab)
            make.top.equalTo(titleLab.snp.bottom).offset(5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
