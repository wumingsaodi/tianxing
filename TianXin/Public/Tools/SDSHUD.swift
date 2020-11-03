//
//  SDSHUD.swift
//  TianXin
//
//  Created by SDS on 2020/9/25.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import PKHUD
class SDSHUD: NSObject {
    static func showSuccess(_ successmsg:String){
//        HUD.show(.labeledSuccess(title: successmsg, subtitle: nil))
        HUD.flash(.labeledSuccess(title: successmsg, subtitle: nil))
    }
    static func showError(_ error:String?){
//        HUD.show(.labeledError(title: error, subtitle: nil))
//        HUD.flash(.labeledError(title: <#T##String?#>, subtitle: <#T##String?#>))
        
        HUD.flash(.label(error))
//        HUD.flash(.labeledError(title: error, subtitle: nil))
    }
    static func showloading(){
        HUD.show(.progress)
    }
    static func hide(){
        HUD.hide(animated: true)
    }
}
