//
//  TaskListModel.swift
//  TianXin
//
//  Created by SDS on 2020/10/26.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class TaskListModel: BaseModel {

     var dict_sort =  0
     var dict_value =  ""
    var taskList:[TaskDdetailModel] =  [TaskDdetailModel]()
     var dict_label =  ""
}

class  TaskDdetailModel: BaseModel{
var task_icon =  ""
var task_reward =  0
var coin_type =  0
var is_finsh:Bool =  false
var task_title =  ""
var task_content =  ""
var id =  0
var type =  ""
var task_toview =  0
var target_num =  0
}
