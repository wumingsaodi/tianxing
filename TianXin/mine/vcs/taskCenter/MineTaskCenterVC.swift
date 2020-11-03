
//
//  MineTaskCenterVC.swift
//  TianXin
//
//  Created by SDS on 2020/10/10.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import MJRefresh
class MineTaskCenterVC: SDSBaseVC {
    var models: [TaskListModel] =  [TaskListModel](){
        didSet{
            self.tableView.reloadData()
        }
    }
    
//    let headers:[String] = ["新手任务","日常任务","推广任务","推广小帖士"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "任务中心"
        setUI()
        requestTaskList()
    }
    func  setUI(){
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(KnavHeight)
            make.bottom.equalToSuperview()
        }
    }

    lazy var tableView:UITableView = {
        let tab = SDSTableView.CreateTableView()
        tab.backgroundColor = baseVCBackGroudColor_grayWhite
        tab.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {[weak self] in
            self?.requestTaskList()
        })
        tab.dataSource = self
        tab.delegate = self
        tab.register(UINib.init(nibName: "MineTaskHeaderFirst", bundle: nil), forHeaderFooterViewReuseIdentifier: MineTaskHeaderFirst.className())
        tab.register(UINib.init(nibName: "MineTaskHeadersecond", bundle: nil), forHeaderFooterViewReuseIdentifier: MineTaskHeadersecond.className())
        tab.register(UINib.init(nibName: "MineTaskCell", bundle: nil), forCellReuseIdentifier: MineTaskCell.className())
        return tab
    }()
}
extension MineTaskCenterVC:UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count + 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
                    return 1
                }
        return models[section - 1 ].taskList.count
//        if section == 0 {
//            return 1
//        } else  if section == 1 {
//            return 2
//        }
//        else  if section == 2 {
//            return 2
//        }
//        else  if section == 3 {
//            return 5
//        }
//        else  if section == 4 {
//            return 1
//        }
//        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3 {
            return 83.5
        }else if indexPath.section == 0 {
            return 0.01
        }
        return 70
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if  section == 0 {
            return 510
        }
        return  44
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell.init()
            return cell
        }
    
        let cell = tableView.dequeueReusableCell(withIdentifier: MineTaskCell.className()) as! MineTaskCell
        let model = models[indexPath.section - 1].taskList[indexPath.row]
       
        if indexPath.section == models.count {
            cell.setModel(model: model, isdoneButHide: true)
        }else{
            cell.setModel(model: model)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            let head = tableView.dequeueReusableHeaderFooterView(withIdentifier:  MineTaskHeaderFirst.className()) as! MineTaskHeaderFirst
            return head
        }
//        let realSection = section - 1
        let  head = tableView.dequeueReusableHeaderFooterView(withIdentifier: MineTaskHeadersecond.className()) as! MineTaskHeadersecond
        head.setTitle(title: models[section - 1].dict_label)
        return  head
    }
    
}

extension MineTaskCenterVC {
    func requestTaskList(){
        let vm = TaskListViewModel()
        vm.requestTaskList { [weak self] (modles) in
            self!.models = modles
        }
    }
}
