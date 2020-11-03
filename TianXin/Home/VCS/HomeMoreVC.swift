//
//  HomeMoreVC.swift
//  TianXin
//
//  Created by SDS on 2020/9/21.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class HomeMoreVC: SDSBaseVC {
  lazy  var topView:MoreTopView = {
    let imgtitles  = ["img_zhongwenzimu","img_youmajingpin","img_wumajingpin","img_wanghongzhubo","img_surenshipin","img_oumeiseqing","img_guochanzipai","img_chengrendongman"]
    var imgs:[UIImage] = [UIImage]()
    for i in 0..<imgtitles.count {
        let img = UIImage(named: imgtitles[i])
        imgs.append(img!)
    }
    let view = MoreTopView.init(images: imgs) { (index, but) in
        //
    }
    return view
    }()
 lazy   var tableView:SDSTableView = {
    let tab = SDSTableView.CreateTableView().sdsNumOfRows(block: { (idex) -> Int in
        return 10
    }).sdsRegisterCell(cellClass: HomeMoretableViewCell.className(), cellBlock: { (indeaPath, cell) in
      
    }, height: { (_) -> CGFloat in
        return HomeMoretableViewCell.cellH
    }).sdsRegisterHeader(headerClass: HomeMoreTableViewHeader.className(), headerBlock: { (_, _) in
        
    }, height: { (_) -> CGFloat in
        return HomeMoreTableViewHeader.headerH
    }).sdsDidSelectCell { (idexPath) in
    
    }
    return tab
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "更多分类"
        self.view.backgroundColor = baseVCBackGroudColor_grayWhite
        setUI()
    }
    func  setUI() {
        self.view.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(KnavHeight + 10)
            make.left.right.equalToSuperview()
        }
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom).offset(5)
            make.left.right.bottom.equalToSuperview()
        }
    }
 
}
