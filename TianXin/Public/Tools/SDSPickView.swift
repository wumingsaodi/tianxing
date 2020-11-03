//
//  SDSPickView.swift
//  TianXin
//
//  Created by SDS on 2020/9/28.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class SDSPickView: UIView {
    var title:String?
    var subtitles:[String] = [String]()
    var selectedStr:String = ""
    var selectedIndex:Int = -1
    var selectedBlock:((Int,String)->Void)!
    var titleL:UILabel!
    
    init(title:String?,subTitles:[String],selectedBlock:@escaping ((Int,String)->Void)) {
        super.init(frame: .zero)
        self.title = title
        self.subtitles = subTitles
       self.selectedBlock = selectedBlock
        self.frame = CGRect(x: 0, y: KScreenH - 250 , width: Configs.Dimensions.screenWidth, height: 250)
        setUI()
    
    }
    func         set(title:String?,subTitles:[String],selectedBlock:@escaping ((Int,String)->Void)) {
        self.title = title
        self.subtitles = subTitles
        self.selectedBlock = selectedBlock
        self.titleL.text = title
        pickView.reloadAllComponents()
    }
    override func willMove(toSuperview newSuperview: UIView?) {
        newSuperview?.insertSubview(self.cover, belowSubview: self)
        super.willMove(toSuperview: newSuperview)
    }
    lazy var cover:UIView = {
        let cover = UIView()
             cover.backgroundColor = .init(white: 0, alpha: 0.3)
        cover.frame = UIScreen.main.bounds
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(cancel))
        cover.addGestureRecognizer(tap)
        return cover
    }()
    func  setUI(){
     
        self.backgroundColor = .white
        //
        self.cornor(conorType: UIRectCorner.init(arrayLiteral: .topLeft,.topRight), reduis: 13)
        let bgv = UIView()
        bgv.backgroundColor = .Hex("#FFF8F8F8")
        self.addSubview(bgv)
        let cancelBut = UIButton.createButWith(title: "取消", titleColor: .Hex("#FF87827D"), font: .pingfangSC(18)) { (_) in
            self.cancel()
        }
        titleL = UILabel.createLabWith(title: self.title, titleColor: .Hex("#FF87827D"), font: .pingfangSC(16))
    
        bgv.addSubview(titleL)
        titleL.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        //
        bgv.addSubview(cancelBut)
        cancelBut.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
        }
        let sureBut = UIButton.createButWith(title: "确定", titleColor: mainYellowColor, font: .pingfangSC(18)) {[weak self] (_) in
            self?.selectedBlock(self!.selectedIndex,self?.selectedStr ?? "")
            self?.cancel()
        }
        bgv.addSubview(sureBut)
        sureBut.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
        }
        self.addSubview(bgv)
        bgv.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        self.addSubview(pickView)
        pickView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(bgv.snp.bottom)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var pickView:UIPickerView = {
        let pick = UIPickerView()
        pick.delegate = self
        pick.dataSource = self
        return pick
    }()
    
    @objc func cancel(){
        self.removeFromSuperview()
        self.cover.removeFromSuperview()
    }
}
extension SDSPickView:UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return subtitles.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return subtitles[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedStr = subtitles[row]
        selectedIndex = row
    }
    
}
