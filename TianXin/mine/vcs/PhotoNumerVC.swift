//
//  PhotoNumerVC.swift
//  TianXin
//
//  Created by SDS on 2020/9/28.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
enum YanZhengType:Int {
    case photo = 0
    case email = 1
}
class PhotoNumerVC: SDSBaseVC {
    @IBOutlet weak var yanzhengBut: UIButton!
    @IBOutlet weak var sureBut: UIButton!
    @IBOutlet weak var yanzhengF: UITextField!
    @IBOutlet weak var yanzhengL: UILabel!
    @IBOutlet weak var photoF: UITextField!
    
    @IBOutlet weak var photoL: UILabel!
    lazy var vm:UserInfoViewModel = {
        return UserInfoViewModel()
    }()
    
    var times:Int = 60
    var secoendTimer:Timer?
    var type:YanZhengType = .photo
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "绑定手机号"
        if type == .email {
            title = "绑定邮箱"
            photoL.text = "邮箱"
            photoF.placeholder = "请输入邮箱地址"
            yanzhengL.text = "邮箱证码"
            photoF.placeholder = "请输入邮箱验证码"
        }
        // Do any additional setup after loading the view.
    }
    @IBAction func yazhengbutClick(_ sender: UIButton) {
        if !self.verificate() {
            return
        }
        if self.type == YanZhengType.photo {
            vm.requistSendPhoneCode(phone: self.photoF.text!) {[weak self] in
                self?.setTimerForBut()
            }
        }else{
            vm.requistSendEmailCode(email: self.photoF.text!) {[weak self] in
                self?.setTimerForBut()
            }
        }
       

    }
    deinit {
        if self.secoendTimer != nil {
            self.secoendTimer?.invalidate()
            self.secoendTimer = nil
        }
    }
    @IBAction func yanZhengFChanged(_ sender: UITextField) {
      setSureButEnable()
    }
    
    @IBAction func photoFChanged(_ sender: UITextField) {
        setSureButEnable()
    }
    
    func setSureButEnable() {
             if photoF.text?.count ?? 0 > 0 && yanzhengF.text?.count ?? 0 > 0 {
               sureBut.isEnabled = true
               let backImg = UIImage.CreateGradienImg(colors: [.Hex("#FFFFD26B"),.Hex("#FFF8944B")])
               sureBut.setBackgroundImage(backImg, for: .normal)
                sureBut.setTitleColor(.white, for: .normal)
           }else{
               sureBut.isEnabled  = false
               sureBut.setTitleColor(.black, for: .normal)
               sureBut.backgroundColor = .gray
               sureBut.setBackgroundImage(nil, for: .normal)
               sureBut.setTitleColor(.Hex("#D3D3D3"), for: .normal)
           }
    }
    @IBAction func sureButClick(_ sender: UIButton) {
        //
        if self.type == .photo {
            vm.requistUploadIphone(phone: photoF.text!, code: yanzhengF.text!){
                SDSHUD.showSuccess("绑定手机号成功")
                self.navigationController?.popViewController(animated: true)
            }
        }else{
            vm.requistUploadEmail(email: photoF.text!, code: yanzhengF.text!){[weak self] in
                SDSHUD.showSuccess("绑定邮箱成功")
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func verificate() ->Bool {
      if  photoF.text?.count ?? 0 == 0{
            SDSHUD.showError("请输入")
        return false
        }
        if self.type == .photo {
            if photoF.text?.count ?? 0 != 11 {
                SDSHUD.showError("请输入11位数手机号")
                return false
            }
        }else{
            if  !photoF.text!.contains("@") || !(photoF.text!.hasSuffix(".com") || photoF.text!.hasSuffix(".cn")){
                SDSHUD.showError("邮箱格式不对")
                return  false
            }
        }
        return true
    }
   
}


//MARK: - actions
extension PhotoNumerVC {
    func setTimerForBut(){
        let sender = self.yanzhengBut!
        sender.isEnabled = false
      secoendTimer =   Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {[weak self] (timer) in
        self!.times -= 1
            if self!.times < 0 {
                timer.invalidate()
               sender.isEnabled = true
                sender.setTitleColor(mainYellowColor, for: .normal)
                sender.borderColor = mainYellowColor
                sender.setTitle("获取验证码", for: .normal)
            }else{
                sender.borderColor = .gray
                sender.setTitleColor(.gray, for: .normal)
                sender.setTitle("\(self!.times)秒获取", for: .normal)
        }
        }
    }
}
