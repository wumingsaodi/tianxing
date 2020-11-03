//
//  SDSTableView.swift
//  TianXin
//
//  Created by SDS on 2020/9/18.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import MJRefresh
class SDSTableView: UITableView {
    var orginY:CGFloat = .zero
    /**
     只有delegate 是 SDSTableView 才生效
     */
    var tableViewScrollToTopOrBottom:((_ isTop:Bool, _ offsetY:CGFloat)-> Bool)?
    var isHaveSelectStye:Bool = false
    var page:Int = 1
    lazy var noDataView:UIView = {
      let bgv = UIView()
        let imgv = UIImageView(image: UIImage(named: "nodata"))
        bgv.addSubview(imgv)
        let lab = UILabel.createLabWith(title: "没有数据", titleColor: .Hex("#FFD7D7D7"), font: .pingfangSC(15))
        bgv.addSubview(lab)
        lab.tag = 1001
        imgv.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        lab.snp.makeConstraints { (make) in
            make.top.equalTo(imgv.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        return bgv
    }()
    func sdsnoDataTite(_ title:String) -> SDSTableView {
        let lab = noDataView.viewWithTag(1001) as! UILabel
        lab.text = title
        return self
    }
    static func CreateTableView()->SDSTableView {
        let table = SDSTableView()
        table.delegate = table
        table.dataSource = table
        table.addSubview(table.noDataView)
        table.noDataView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
//        table.separatorStyle = .none
        table.tableFooterView = UIView()
        NotificationCenter.default.addObserver(table, selector: #selector(sdsRequestSuccess), name: NSNotification.Name.init(NetWorkingRequistSuccess), object: nil)
        NotificationCenter.default.addObserver(table, selector: #selector(sdsMJEndReresh), name: NSNotification.Name.init(NetWorkingRequistError), object: nil)
        return table
    }
    
    func sdsNumOfSections( block:@escaping ()->Int) -> SDSTableView {
        self.SectionsNumBlock = block
        return self
    }
    func sdsNumOfRows(block:@escaping (_ section:Int)->Int)->SDSTableView {
        self.rowsForSectionBlock = block
        return self
    }
    func sdsRegisterHeader(headerClass:String,isNib:Bool = false,headerBlock:@escaping ((_ section:Int,_ header:UITableViewHeaderFooterView)->Void),height:@escaping (_ section:Int)->CGFloat)->SDSTableView{
        if isNib {
            let nib = UINib.init(nibName: headerClass, bundle: nil)
            self.register(nib, forHeaderFooterViewReuseIdentifier: headerClass)
        }else {
             self.register(NSClassFromString(headerClass), forHeaderFooterViewReuseIdentifier: headerClass)
        }
        self.headerBlock = headerBlock
        self.headerIdentifier = headerClass
        self.headerHeightBlock = height
        return self
    }
    func sdsRegisterFooter(footerClass:String,isNib:Bool = false,footerBlock:@escaping ((_ section:Int,_ header:UITableViewHeaderFooterView)->Void),height:@escaping (_ section:Int)->CGFloat){
         if isNib {
             let nib = UINib.init(nibName: footerClass, bundle: nil)
             self.register(nib, forHeaderFooterViewReuseIdentifier: footerClass)
         }else {
              self.register(NSClassFromString(footerClass), forHeaderFooterViewReuseIdentifier: footerClass)
         }
         self.headerBlock = footerBlock
         self.headerIdentifier = footerClass
         self.headerHeightBlock = height
     }
    func sdsRegisterCell(cellClass:String,isNib:Bool = false ,cellBlock:@escaping ((_ indepath:IndexPath,_ cell:UITableViewCell)->Void),height:@escaping (_ indexPath:IndexPath)->CGFloat)->SDSTableView{
           let zclass: AnyClass? =  NSClassFromString(cellClass)
           sdsCellIndetifier = cellClass
           if !isNib {
                self.register(zclass, forCellReuseIdentifier: cellClass)
           }else{
               let nib = UINib.init(nibName: cellClass, bundle: nil)
                self.register(nib, forCellReuseIdentifier: cellClass)
           }
           self.cellHeightBlock = height
           self.cellBlock = cellBlock
           return self
       }
    func sdsMJRerechBlock(isCanHeard:Bool = false,block:@escaping(_ isHeader:Bool)->Void)->SDSTableView{
        if isCanHeard {
            self.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {[weak self] in
                self!.page = 1
                block(true)
            })
        }
          
           self.mj_footer = MJRefreshAutoStateFooter.init(refreshingBlock: {
               block(false)
           })
           return self
       }
       func sdsDidSelectCell(block:@escaping (_ indexPath:IndexPath)->Void) -> SDSTableView {
           self.didSelectedBlock = block
           return self
       }
    
    @objc func sdsRequestSuccess(){
        self.page += 1
        sdsMJEndReresh()
    }
    @objc func sdsMJEndReresh(){
        self.mj_header?.endRefreshing()
        self.mj_footer?.endRefreshing()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
private    var SectionsNumBlock:(()->Int) = {
        return 1
    }
 private   var rowsForSectionBlock:((Int)->Int) = { _ in
        return 0
    }
    private var cellHeightBlock:((IndexPath)->CGFloat) = {_ in
        return 44
    }
    
    
    
 private   var cellBlock:(IndexPath,UITableViewCell)->Void = {_,_  in
        
    }
    private var sdsCellIndetifier:String = ""
   
    private var headerIdentifier:String = ""
    private var headerBlock:((Int,UITableViewHeaderFooterView)->Void) = {_,_ in
    }
    private var headerHeightBlock:(Int)->CGFloat = { _ in
        return  0
    }
    
    private var footerIdentifier:String = ""
    private var footerBlock:((Int,UITableViewHeaderFooterView)->Void) = {_,_ in
    }
    private var footerHeightBlock:(Int)->CGFloat = { _ in
        return  0
    }
 
    private var didSelectedBlock:(IndexPath)->Void = {_ in
        
    }
   
}
extension SDSTableView:UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.SectionsNumBlock()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let index = self.rowsForSectionBlock(section)
        if  index == 0 {
            self.noDataView.isHidden = false
        }else {
            self.noDataView.isHidden = true
        }
        return index
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeightBlock(indexPath)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeightBlock(section)
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return footerHeightBlock(section)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView .dequeueReusableHeaderFooterView(withIdentifier: self.headerIdentifier)
        if header != nil {
            self.noDataView.isHidden = true
            self.headerBlock(section,header!)
            return header

        }
        return UIView()
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: self.footerIdentifier)
        if footer != nil {
            self.noDataView.isHidden = true
            self.footerBlock(section,footer!)
             return footer
        }else {
           return UIView()
        }
        
       
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 { //最顶部
            if let block = tableViewScrollToTopOrBottom{
                if !block(true,scrollView.contentOffset.y - orginY){
                    scrollView.contentOffset.y = 0
                }
            }
        }//else if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height {//最底部了
        else {//向上
            if let block = tableViewScrollToTopOrBottom{
                if   !block(false,scrollView.contentOffset.y - orginY ){
                   scrollView.contentOffset.y = orginY
                }
            }
        }
        orginY = scrollView.contentOffset.y
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
     let  cell =    tableView.dequeueReusableCell(withIdentifier: sdsCellIndetifier)
        if cell != nil {
            self.noDataView.isHidden = true
               self.cellBlock(indexPath,cell!)
            if  !self.isHaveSelectStye {
                cell?.selectionStyle = .none
            }
                 return cell!
        }
     return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.didSelectedBlock(indexPath)
    }
//    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
}
