//
//  SDSPlayerVC.swift
//  TianXin
//
//  Created by SDS on 2020/10/22.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class SDSPlayerVC: UIViewController {
    var url:URL?{
        didSet{
                playV.url = url
        }
    }
    var coverImgUrl:String = ""{
        didSet{
            playV.coverImgUrl = coverImgUrl
        }
    }
    ///是不是允许已进入就播放
    var isCanBeiginPlay:Bool = false {
        didSet {
            self.playV.isCanBeiginPlay = isCanBeiginPlay
        }
    }
    lazy var playV:SDSAVView = {
       return SDSAVView()
    }()
    var fullScreenBlock:((_ isFull:Bool)->Void)?{
        didSet{
            playV.fullScreenBlock = fullScreenBlock
        }
    }
    var ToolsHideOrShow:((_ isShow:Bool)->Void)?{
        didSet{
            playV.showOrHideToolsBlock = ToolsHideOrShow
        }
    }
    var fullScreenView:UIView? {
        didSet{
            playV.fullParentView = fullScreenView
        }
    }
    var  isCanHideTools:Bool = true {
        didSet{
            self.playV.isCanHideTools = isCanHideTools
        }
    }
    init(url:String,coverImgUrl:String) {
        super.init(nibName: nil, bundle: nil)
        if let playurl = URL.init(string: url) {
            self.url = playurl
            self.playV.url = playurl
        }
        self.coverImgUrl = coverImgUrl
        self.playV.coverImgUrl = coverImgUrl
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        self.isCanHideTools = false
//        self.playV.isCanHideTools = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(playV)
        playV.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.playV.pasuse()
    }
    deinit {
        NJLog("视频播放器销毁了")
    }

}
extension SDSPlayerVC {
    func  pasuse(){
        self.playV.pasuse()
    }
    func  play(){
        self.playV.play()
    }
}
