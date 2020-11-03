//
//  SDSPlayerVCTEm.swift
//  TianXin
//
//  Created by SDS on 2020/9/23.
//  Copyright © 2020 SDS. All rights reserved.
//

//import UIKit
//import AVKit
//import SnapKit
//class SDSPlayerVCTEm: UIViewController {
//    fileprivate var originParentView: UIView?
//
//    var isFinished: Bool = false
//    let  margin:CGFloat = 10
//    let leftRightMargin:CGFloat = 20
//    var player:AVPlayer!
//    var playerItem: AVPlayerItem!
//    var url:URL?{
//        didSet{
//            if self.isSetPlayerConfig {
//                guard let url = url else {
//                    return
//                }
//                reStart()
//                removeOberVerForPlayItem()
//                self.playerItem = AVPlayerItem.init(url: url)
//                //重新注册了一个 playerItem ，就得重新添加
//                addObservers()
//                self.player.replaceCurrentItem(with: self.playerItem)
//
//            }
//        }
//    }
//    /**
//     是不是全屏状态
//     */
//    var fullScreenBlock:((_ isFull:Bool)->Void)?
//   private func reStart() {
//   slider.value = 0
//   playLab.snp.remakeConstraints { (make) in
//        make.left.centerY.equalToSuperview()
//        make.width.equalTo(0.1)
//        make.height.equalTo(sliderH)
//    }
//    bufferTimeLabel.snp.remakeConstraints { (make) in
//        make.left.centerY.equalToSuperview()
//        make.width.equalToSuperview().multipliedBy(0.001)
//        make.height.equalTo(sliderH)
//    }
//   playTimeLabl.text = "00:00"
//   totalTimeLab.text = "00:00"
//    }
//    //
//    lazy  var bufferTimeLabel : UIView = {
//        let lab = UIView()
//        lab.backgroundColor = .red
//        return lab
//    }()
//    lazy  var playLab : UIView = {
//        let lab = UIView()
//        lab.backgroundColor = .yellow
//        return lab
//    }()
//    var sliderH:CGFloat = 3
//    lazy var slider:UISlider = {
//        let slider = UISlider()
//      let crect =   slider.trackRect(forBounds: .zero)
//        slider.layoutIfNeeded()
//        sliderH = crect.size.height
//        slider.addSubview(bufferTimeLabel)
//        bufferTimeLabel.snp.makeConstraints { (make) in
//            make.left.centerY.equalToSuperview()
//            make.width.equalToSuperview().multipliedBy(0.001)
//            make.height.equalTo(crect.size.height)
//        }
//        slider.addSubview(playLab)
//        playLab.snp.makeConstraints { (make) in
//            make.left.centerY.equalToSuperview()
//            make.width.equalToSuperview().multipliedBy(0.001)
//            make.height.equalTo(crect.size.height)
//        }
//        slider.addTarget(self, action:#selector(sliderValueDidChange(sender:)) , for: .valueChanged)
//        slider.setThumbImage(UIImage(named: "icon_progress bar"), for: .normal)
//        slider.tintColor = .clear
//        return slider
//    }()
//    lazy var playTimeLabl:UILabel = {
//        let lab = UILabel.createLabWith(title: "00:00", titleColor: .white, font: .pingfangSC(17))
//        return lab
//    }()
//    lazy var totalTimeLab:UILabel = {
//        let lab = UILabel.createLabWith(title: "00:00", titleColor: .white, font: .pingfangSC(17))
//        return lab
//    }()
//    lazy var pasueBut:UIButton = {
//        let but = UIButton.createButWith( image: UIImage(named: "icon_time out small")) {[weak self] (but) in
//            if !but.isSelected {//播放
//                self!.play()
//            }else{//暂停
//                self?.pasuse()
//            }
////            but.isSelected = !but.isSelected
//        }
//        but.setImage(UIImage(named: "icon_play"), for: .selected)
////        but.isSelected = true
//        return but
//    }()
//    lazy var bigPlayBut:UIButton = {
//
//        let but = UIButton.createButWith(image:UIImage(named: "icon_time out")) {[weak self] (_) in
//            self!.play()
//        }
//        return but
//    }()
//    lazy var soundBut:UIButton = {
//        let but = UIButton.createButWith( image: UIImage(named: "icon_sound")) { [weak self] (but) in
//
//            but.isSelected = !but.isSelected
//            if self!.isSetPlayerConfig {
//                self!.player.volume = but.isSelected ? 0 : 1
//            }
//        }
//        but.setImage(UIImage(named: "icon_sound_stop"), for: .selected)
//        return but
//    }()
//    var orginFrame:CGRect = .zero
//    var bigConstions:[NSLayoutConstraint] = [NSLayoutConstraint]()
//    var isFullScreen:Bool = false
//
//    lazy var  fullScreenBut:UIButton = {
//        let but = UIButton.createButWith( image: UIImage(named: "icon_full screen")) {[weak self] (but) in
//            but.isSelected = !but.isSelected
//            if let screenBlock = self?.fullScreenBlock {
//                screenBlock(but.isSelected)
//            }
//            self?.issetOrginConstraints = true
////            if !self!.isFullScreen {
////                                self?.view.updateConstraintsIfNeeded()
////                                self?.orginConstraints = self?.view.constraints
////                                self?.view.layoutIfNeeded()
////                                self?.orginFrame = self!.view.frame
////
////
////                self?.isFullScreen = true
////            }
//
//            if but.isSelected {
//                kAppdelegate.blockRotation = .landscapeRight
//                self?.orginConstraints = self?.view.constraints
////                self?.view.layoutIfNeeded()
////                self?.orginFrame = self!.view.frame
//
//
//                self?.enterFullScreen()
//                self?.bigConstions = (self?.view.constraints)!
//            }else{
//                kAppdelegate.blockRotation = .portrait
//                self?.exitFullScreen()
//
//
//            }
//
//        }
//        but.setImage(UIImage(named: "icon_unfull screen"), for: .selected)
//        return but
//    }()
//
//    var playerLayer:AVPlayerLayer?
//    var viewChagetoSmallBlock:((UIView)->Void)?
//    var coverImgUrl = "" {
//        didSet{
//            coverImgView.loadUrl(urlStr: coverImgUrl, placeholder: #imageLiteral(resourceName: "defualt"))
//        }
//    }
//    lazy var coverImgView:UIImageView = {
//        let imgv = UIImageView()
//        imgv.contentMode = .scaleAspectFit
//        return imgv
//    }()
//    init(url:String,viewChagetoSmallBlock:@escaping (UIView)->Void,coverImgUrl:String) {
//        super.init(nibName: nil, bundle: nil)
//        self.url = URL(string: url)
//        self.viewChagetoSmallBlock = viewChagetoSmallBlock
//        self.coverImgUrl = coverImgUrl
//    }
//
//        required init?(coder: NSCoder) {
//            super.init(coder: coder)
//
//        }
//    var orginConstraints:[NSLayoutConstraint]?
//    var snpConstrain:ConstraintViewDSL!
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.view.backgroundColor = .black
////        snpConstrain =  self.view.snp
////      setPlayerConfig()
//        // 不支持storyboard，外面手动调用
//        setUI()
//    }
//    func setPlayerConfig() -> Bool {
//
//        if url == nil {
//            SDSHUD.showError("url不合法或者为空")
//            return false
//        }
//        coverImgView.removeFromSuperview()
//        isSetPlayerConfig = true
//         //创建媒体资源管理对象
//
//        self.playerItem = AVPlayerItem.init(url: url!)
//               //创建ACplayer：负责视频播放
//               self.player = AVPlayer.init(playerItem: playerItem)
//               self.player.rate = 1.0
//        self.player.volume = self.soundBut.isSelected ? 0 : 1.0
////               //不自动播放
////               self.player.pause()
//               //创建显示视频的图层
//               playerLayer =    AVPlayerLayer.init(player: self.player)
//               playerLayer!.videoGravity = .resizeAspect
//               playerLayer!.frame =  self.view.bounds
////               self.view.layer.addSublayer(playerLayer)
//          self.view.layer.insertSublayer(playerLayer!, at: 0)
//               //观察属性
//               addObservers()
//               //播放时间进度
//               setPalyProgress()
//        return true
//    }
//    var isSetPlayerConfig:Bool = false
//    func setPalyProgress(){
//        player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main) { [weak self] (time) in
//            let playTime = CMTimeGetSeconds(time)
//            let totalTiem  = CMTimeGetSeconds((self?.player.currentItem!.duration) ?? CMTimeMake(value: 0, timescale: 1))
//            if playTime.isNaN || totalTiem.isNaN {
//                return
//            }
//            self?.slider.value = Float(playTime/totalTiem)
//            self?.playLab.snp.remakeConstraints { (make) in
//                make.left.centerY.equalToSuperview()
//                make.width.equalToSuperview().multipliedBy(Float(playTime/totalTiem))
//                make.height.equalTo(self!.sliderH)
//            }
//            self?.playTimeLabl.text = Date.stringFromSeconds(secondes: Int(playTime))
//            self?.totalTimeLab.text = Date.stringFromSeconds(secondes: Int(totalTiem))
//        }
//    }
//    func addObservers(){
//        playerItem.addObserver(self, forKeyPath: "status", options: .new
//            , context: nil)
//        self.playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
//        self.playerItem.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
//        self.playerItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(playToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
//    }
//    func setUI() {
//        //
//        self.view.addSubview(coverImgView)
//        coverImgView.loadUrl(urlStr: coverImgUrl, placeholder: "")
//        coverImgView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
//        //
//        self.view.addSubview(bigPlayBut)
//        bigPlayBut.snp.makeConstraints { (make) in
//            make.center.equalToSuperview()
//        }
//        //
//        self.view.addSubview(pasueBut)
//        pasueBut.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(leftRightMargin)
//            make.bottom.equalToSuperview().offset(-12)
//            make.size.equalTo(CGSize(width: 19.5, height: 19.5))
//        }
//        //
//        self.view.addSubview(playTimeLabl)
//        playTimeLabl.snp.makeConstraints { (make) in
//            make.centerY.equalTo(pasueBut)
//            make.left.equalTo(pasueBut.snp.right).offset(margin)
//
//        }
//        //
//        self.view.addSubview(slider)
//
//        //
//        self.view.addSubview(totalTimeLab)
//
//        //
//        self.view.addSubview(soundBut)
//
//        self.view.addSubview(fullScreenBut)
//
//        fullScreenBut.snp.makeConstraints { (make) in
//            make.centerY.equalTo(pasueBut)
//            make.right.equalToSuperview().offset(-leftRightMargin)
//            make.size.equalTo(CGSize(width: 19.5, height: 19.5))
//        }
//        soundBut.snp.makeConstraints { (make) in
//                 make.centerY.equalTo(pasueBut)
//                 make.right.equalTo(fullScreenBut.snp.left).offset(-margin)
//            make.size.equalTo(CGSize(width: 19.5, height: 19.5))
//
//             }
//        totalTimeLab.snp.makeConstraints { (make) in
//                   make.centerY.equalTo(pasueBut)
//                   make.right.equalTo(soundBut.snp.left).offset(-margin)
//               }
//        slider.snp.makeConstraints { (make) in
//                  make.centerY.equalTo(pasueBut)
//                  make.left.equalTo(playTimeLabl.snp.right).offset(margin)
//            make.right.equalTo(totalTimeLab.snp.left).offset(-margin)
//              }
//    }
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        self.pasuse()
//
//    }
//    func removeOberVerForPlayItem(){
//        self.playerItem.removeObserver(self, forKeyPath: "status", context: nil)
//         self.playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges", context: nil)
//         self.playerItem.removeObserver(self, forKeyPath: "playbackBufferEmpty", context: nil)
//         self.playerItem.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp", context: nil)
//
//    }
//    deinit {
//        if isSetPlayerConfig {
//            removeOberVerForPlayItem()
//            self.player = nil
//            self.playerItem = nil
//            self.playerLayer?.removeFromSuperlayer()
//            self.player = nil
////                    self.player.removeTimeObserver(self)
//        }
//
//        NotificationCenter.default.removeObserver(self)
////        self.player = nil
////        self.playerItem = nil
////        self.player.removeTimeObserver(self.player)
////        self.player.addPeriodicTimeObserver(forInterval: <#T##CMTime#>, queue: <#T##DispatchQueue?#>, using: <#T##(CMTime) -> Void#>)
//    }
//    var issetOrginConstraints :Bool = false
//    override func viewDidLayoutSubviews() {
//        if !issetOrginConstraints {
//            self.orginConstraints = self.view.constraints
//        }
//        if playerLayer != nil {
//             playerLayer!.frame = self.view.bounds
//        }
//
//    }
//}
//
////MARK: -action
//extension SDSPlayerVCTEm{
//    func play(){//播放
//        if !isSetPlayerConfig {
//            if  !setPlayerConfig() {
//                return
//            }
//        }
//        if isFinished {
//            self.player.seek(to: CMTime.zero)
//            isFinished = false
//        }
//        pasueBut.isSelected = true
//        self.bigPlayBut.isHidden = true
//         player.play()
////        if self.player.currentItem!.status == .readyToPlay {
////            player.play()
////        }else{
////            NJLog("播放器尚未准备好播放")
////        }
//
//    }
//    func pasuse(){//暂停
//        if !isSetPlayerConfig {
//            return
//        }
//        pasueBut.isSelected = false
//        self.bigPlayBut.isHidden = false
//        player.pause()
//    }
//    //快进播放
//    @objc  func sliderValueDidChange(sender:UISlider){
//        if !isSetPlayerConfig {
//            self.play()
//            return
//        }
//        if player.status == .readyToPlay {
//            let time:Float64 = Float64(sender.value)*CMTimeGetSeconds(player.currentItem!.duration)
//            if time.isNaN {
//                return
//            }
//            let seekTime = CMTimeMake(value: Int64(time), timescale: 1)
//            player.seek(to: seekTime)
//        }
//    }
//    @objc func  playToEndTime(){
//        NJLog("播放完成")
//        isFinished = true
//        self.pasuse()
//    }
//}
////MARK: -视频观察者
//extension SDSPlayerVCTEm {
//    //KVO观察
//    override  func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "status"{
//            switch self.player.currentItem!.status {
//            case .readyToPlay:
//                self.play()
//                break
//            case .failed:
//                NJLog("播放器获取资源失败")
//            case .unknown :
//                NJLog("播放获取资源发生未知错误")
//
//            @unknown default:
//                break
//            }
//        }else if keyPath == "loadedTimeRanges"{
//            let loadTimeArray = self.player.currentItem!.loadedTimeRanges
//            //获取最新缓存的区间
//            let newTimeRange : CMTimeRange = loadTimeArray.first?.timeRangeValue ?? CMTimeRange.zero
//            let startSeconds = CMTimeGetSeconds(newTimeRange.start);
//            let durationSeconds = CMTimeGetSeconds(newTimeRange.duration);
//            let totalBuffer = startSeconds + durationSeconds;//缓冲总长度
//            let total = CMTimeGetSeconds(self.player.currentItem!.duration);
//            NJLog("缓存 \(totalBuffer)->\(total)")
//            bufferTimeLabel.snp.remakeConstraints { (make) in
//                make.left.centerY.equalToSuperview()
//                make.width.equalToSuperview().multipliedBy(totalBuffer / total)
//                make.height.equalTo(sliderH)
//            }
////            bufferTimeLabel.snp.updateConstraints{ (make) in
////                make.width.equalToSuperview().multipliedBy(totalBuffer / total)
////            }
////            print("当前缓冲时间：%f",totalBuffer)
//        }else if keyPath == "playbackBufferEmpty"{
//            NJLog("正在缓存视频请稍等")
//        }
//        else if keyPath == "playbackLikelyToKeepUp"{
//            NJLog("缓存好了继续播放")
////            self.play()
//        }
//    }
//
//}
//
//
//extension SDSPlayerVCTEm {
//    fileprivate func enterFullScreen() {
//        // 找到顶层viewcontroller
//        var current = self.parent
//        while current?.parent != nil && !(current!.parent is UINavigationController) {
//            current = current?.parent
//        }
//        originParentView = self.view.superview
//        guard let rootView = current?.view else { return }
//        self.view.frame = rootView.bounds
//        if rootView == originParentView {
//            self.view.superview?.bringSubviewToFront(self.view)
//            self.view.snp.remakeConstraints { (make) in
//                make.edges.equalToSuperview()
//            }
//        } else {
//            rootView.addSubview(self.view)
//        }
//
//    }
//    fileprivate func exitFullScreen() {
//        guard let originParentView = self.originParentView,
//              let parent = self.parent else { return }
//        if originParentView == parent.view {
//            self.view.removeConstraints(self.bigConstions)
//            self.view.addConstraints((self.orginConstraints)!)
//            self.viewChagetoSmallBlock?(self.view)
//        } else {
//            self.view.frame = originParentView.bounds
//            originParentView.addSubview(self.view)
//        }
//    }
//}
