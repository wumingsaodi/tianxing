//
//  TaskListViewModel.swift
//  TianXin
//
//  Created by SDS on 2020/10/26.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
let api_taskList = "/gl/taskcenter/getTaskList"
class TaskListViewModel: NSObject {
    func  requestTaskList(success:@escaping(_ models:[TaskListModel])->Void){
        NetWorkingHelper.normalPost(url: api_taskList, params: [:]) { (dict) in
            guard let dataArr = dict["data"] as? [Any],  let models = [TaskListModel].deserialize(from:dataArr) else{
                SDSHUD.showError("解析错误")
                return
            }
            let  newModels = models.map({$0!})
            success(newModels)
        }
    }
}
