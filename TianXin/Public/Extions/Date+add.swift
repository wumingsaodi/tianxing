//
// Date+add.swift
//  TianXin
//
//  Created by SDS on 2020/9/23.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

extension Date {
    /**
     把秒变成几小时几秒，几天
     */
    static func stringFromSeconds(secondes:Int)->String{
//        var str = ""
        var time = secondes
        let ss = time % 60
        //
        time = time / 60
        let mm = time % 60
     
        //
        time = time / 60
        let hh = time % 24
           if time <= 0 {
                 return String(format: "%02d:%02d",mm, ss)
             }
        time =  time / 24
         let dd = time % 24
          if time <= 0 {
              return String(format: "%02d:%02d:%02d",hh,mm, ss)
          }
        return String(format: "%02d %02d:%02d:%02d",dd,hh,mm, ss)
    }
}
