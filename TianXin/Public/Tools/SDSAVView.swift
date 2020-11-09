//
//  SDSAVView.swift
//  TianXin
//
//  Created by SDS on 2020/10/21.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import AVKit
class SDSAVView: UIView {
    var url:URL?{
        didSet{
            if self.isSetPlayerConfig {
                guard let url = url else {
                    return
                }
                reStart()
                removeOberVerForPlayItem()
                self.playerItem = AVPlayerItem.init(url: url)
                //重新注册了一个 playerItem ，就得重新添加
                addObservers()
                self.player.replaceCurrentItem(with: self.playerItem)
                
            }
        }
    }
    ///是不是允许已进入就播放
    var isCanBeiginPlay:Bool = false
    var fullParentView:UIView? = UIApplication.shared.keyWindow
    
    ///是不是可以隐藏tools
    var isCanHideTools:Bool = true
    /**
     是不是全屏状态
     */
    var fullScreenBlock:((_ isFull:Bool)->Void)?
    var coverImgUrl = "" {
        didSet{
            coverImgView.loadUrl(urlStr: coverImgUrl, placeholder: #imageLiteral(resourceName: "defualt"))
        }
    }
    var showOrHideToolsBlock:((_ isShow:Bool)->Void)?
    
    fileprivate var originParentView: UIView?
    private   var isFinished: Bool = false
    private   let  margin:CGFloat = 10
    private    let leftRightMargin:CGFloat = 20
    private  var player:AVPlayer!
    private   var playerItem: AVPlayerItem!
    private var isToolHide:Bool = false
    private let  toolH:CGFloat = 40
    private func reStart() {
        slider.value = 0
//        playLab.snp.remakeConstraints { (make) in
//            make.left.centerY.equalToSuperview()
//            make.width.equalTo(0.1)
//            make.height.equalTo(sliderH)
//        }
//        bufferTimeLabel.snp.remakeConstraints { (make) in
//            make.left.centerY.equalToSuperview()
//            make.width.equalToSuperview().multipliedBy(0.001)
//            make.height.equalTo(sliderH)
//        }
        playTimeLabl.text = "00:00"
        totalTimeLab.text = "00:00"
    }
    //
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
    var sliderH:CGFloat = 3
    lazy var slider:UISlider = {
        let slider = UISlider()
        let crect =   slider.trackRect(forBounds: .zero)
        slider.layoutIfNeeded()
        sliderH = crect.size.height
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
        slider.addTarget(self, action:#selector(sliderValueDidChange(sender:)) , for: .valueChanged)
        slider.setThumbImage(UIImage(named: "icon_progress bar"), for: .normal)
//        slider.tintColor = .clear
        return slider
    }()
    lazy var playTimeLabl:UILabel = {
        let lab = UILabel.createLabWith(title: "00:00", titleColor: .white, font: .pingfangSC(17))
        return lab
    }()
    lazy var totalTimeLab:UILabel = {
        let lab = UILabel.createLabWith(title: "00:00", titleColor: .white, font: .pingfangSC(17))
        return lab
    }()
    lazy var pasueBut:UIButton = {
        let but = UIButton.createButWith( image: UIImage(named: "icon_time out small")) {[weak self] (but) in
            if !but.isSelected {//播放
                self!.play()
            }else{//暂停
                self?.pasuse()
            }
            //            but.isSelected = !but.isSelected
        }
        but.setImage(UIImage(named: "icon_play"), for: .selected)
        //        but.isSelected = true
        return but
    }()
    lazy var bigPlayBut:UIButton = {
        
        let but = UIButton.createButWith(image:UIImage(named: "icon_time out")) {[weak self] (_) in
            self!.play()
        }
        return but
    }()
    lazy var soundBut:UIButton = {
        let but = UIButton.createButWith( image: UIImage(named: "icon_sound")) { [weak self] (but) in
            
            but.isSelected = !but.isSelected
            if self!.isSetPlayerConfig {
                self!.player.volume = but.isSelected ? 0 : 1
            }
        }
        but.setImage(UIImage(named: "icon_sound_stop"), for: .selected)
        return but
    }()
    var orginFrame:CGRect?
//    var bigConstions:[NSLayoutConstraint]?
//    var OrginConstions:[NSLayoutConstraint]?
    override var bounds: CGRect{
        didSet{
            self.playerLayer?.frame = bounds
        }
    }
    lazy var  fullScreenBut:UIButton = {
        let but = UIButton.createButWith( image: UIImage(named: "icon_full screen")) {[weak self] (but) in
            but.isSelected = !but.isSelected
            if let screenBlock = self?.fullScreenBlock {
                screenBlock(but.isSelected)
            }
            self?.issetOrginConstraints = true
            if but.isSelected {
                self?.enterFullScreen()
            }else{
                self?.exitFullScreen()
            }
//            self?.playerLayer?.frame = self!.bounds
            
        }
        but.setImage(UIImage(named: "icon_unfull screen"), for: .selected)
        return but
    }()
    
    var playerLayer:AVPlayerLayer?
//    var viewChagetoSmallBlock:((UIView)->Void)?

    lazy var coverImgView:UIImageView = {
        let imgv = UIImageView()
        imgv.contentMode = .scaleAspectFit
        return imgv
    }()
   convenience init(url:String,coverImgUrl:String) {
        self.init(frame: .zero)
        self.url = URL(string: url)
//        self.viewChagetoSmallBlock = viewChagetoSmallBlock
        self.coverImgUrl = coverImgUrl
  
       
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUI()
    }
    override func removeFromSuperview() {
        pasuse()
//        SDSPlayManager.share.pauseAll()
       
    }
    
    func setPlayerConfig() -> Bool {
        
        if url == nil {
//            SDSHUD.showError("url不合法或者为空")
            return false
        }
        coverImgView.removeFromSuperview()
        isSetPlayerConfig = true
        //创建媒体资源管理对象
        
        self.playerItem = AVPlayerItem.init(url: url!)
        //创建ACplayer：负责视频播放
        self.player = AVPlayer.init(playerItem: playerItem)
        self.player.replaceCurrentItem(with: self.playerItem)
        self.player.rate = 1.0
        self.player.volume = self.soundBut.isSelected ? 0 : 1.0
        //               //不自动播放
        //               self.player.pause()
        //创建显示视频的图层
        playerLayer =    AVPlayerLayer.init(player: self.player)
        playerLayer!.videoGravity = .resizeAspect
        playerLayer!.frame =  self.bounds
        //               self.view.layer.addSublayer(playerLayer)
        self.layer.insertSublayer(playerLayer!, at: 0)
        //观察属性
        addObservers()
        //播放时间进度
        setPalyProgress()
        //
        hideTools()
        return true
    }

    var isSetPlayerConfig:Bool = false
    func setPalyProgress(){
        player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main) { [weak self] (time) in
            if self == nil {
                return
            }
            let playTime = CMTimeGetSeconds(time)
            let totalTiem  = CMTimeGetSeconds((self?.player.currentItem?.duration ?? CMTime.zero)) //?? CMTimeMake(value: 0, timescale: 1))
            if playTime.isNaN || totalTiem.isNaN || totalTiem == 0 {
                return
            }
        
            self?.slider.value = Float(playTime/totalTiem)
//            self?.playLab.snp.remakeConstraints { (make) in
//                make.left.centerY.equalToSuperview()
//                make.width.equalToSuperview().multipliedBy(Float(playTime/totalTiem))
//                make.height.equalTo(self!.sliderH)
//            }
            self?.playTimeLabl.text = Date.stringFromSeconds(secondes: Int(playTime))
            self?.totalTimeLab.text = Date.stringFromSeconds(secondes: Int(totalTiem))
        }
    }
    func addObservers(){
        playerItem.addObserver(self, forKeyPath: "status", options: .new
                               , context: nil)
        self.playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        self.playerItem.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        self.playerItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    lazy var toolsView:UIView = {
        return  UIView()
    }()
    func setUI() {
        let  tap  = UITapGestureRecognizer(target: self, action: #selector(toolsShow))
        self.addGestureRecognizer(tap)
        self.backgroundColor = .black
        //
        self.addSubview(coverImgView)
        coverImgView.loadUrl(urlStr: coverImgUrl, placeholder: "")
        coverImgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
      
        //
        self.addSubview(bigPlayBut)
        bigPlayBut.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        self.addSubview(toolsView)
        toolsView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(toolH)
        }
        //
        toolsView.addSubview(pasueBut)
        pasueBut.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftRightMargin)
            make.bottom.equalToSuperview().offset(-12)
            make.size.equalTo(CGSize(width: 19.5, height: 19.5))
        }
        //
        toolsView.addSubview(playTimeLabl)
        playTimeLabl.snp.makeConstraints { (make) in
            make.centerY.equalTo(pasueBut)
            make.left.equalTo(pasueBut.snp.right).offset(margin)
            
        }
        //
        toolsView.addSubview(slider)
        
        //
        toolsView.addSubview(totalTimeLab)
        
        //
        toolsView.addSubview(soundBut)
        
        toolsView.addSubview(fullScreenBut)
        
        fullScreenBut.snp.makeConstraints { (make) in
            make.centerY.equalTo(pasueBut)
            make.right.equalToSuperview().offset(-leftRightMargin)
            make.size.equalTo(CGSize(width: 19.5, height: 19.5))
        }
        soundBut.snp.makeConstraints { (make) in
            make.centerY.equalTo(pasueBut)
            make.right.equalTo(fullScreenBut.snp.left).offset(-margin)
            make.size.equalTo(CGSize(width: 19.5, height: 19.5))
            
        }
        totalTimeLab.snp.makeConstraints { (make) in
            make.centerY.equalTo(pasueBut)
            make.right.equalTo(soundBut.snp.left).offset(-margin)
        }
        slider.snp.makeConstraints { (make) in
            make.centerY.equalTo(pasueBut)
            make.left.equalTo(playTimeLabl.snp.right).offset(margin)
            make.right.equalTo(totalTimeLab.snp.left).offset(-margin)
        }
        self.perform(block: {[weak self] in
            guard let self = self else { return }
//            if ((self?.isCanBeiginPlay) != nil){
//                self?.play()
//            }
            if self.isCanBeiginPlay {
                self.play()
            }
        }, timel: 0.5)
    }
    func removeOberVerForPlayItem(){
        self.playerItem.removeObserver(self, forKeyPath: "status", context: nil)
        self.playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges", context: nil)
        self.playerItem.removeObserver(self, forKeyPath: "playbackBufferEmpty", context: nil)
        self.playerItem.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp", context: nil)
// ////       player.removeTimeObserver(self)
    }
    deinit {
        NJLog("视频视图销毁了")
        if isSetPlayerConfig {
            removeOberVerForPlayItem()
            SDSPlayManager.share.remove(player: self.player)
            self.playerLayer?.removeFromSuperlayer()
            self.playerItem = nil
            self.player = nil
        }
        
        NotificationCenter.default.removeObserver(self)
        
    }
    var issetOrginConstraints :Bool = false
}

//MARK: -action
extension SDSAVView{
    func play(){//播放
        if url == nil {
            SDSHUD.showError("url不合法或者为空")
            return
        }
        if !isSetPlayerConfig {
            if  !setPlayerConfig() {
                return
            }
        }
        if isFinished {
            self.player.seek(to: CMTime.zero)
            isFinished = false
        }
        pasueBut.isSelected = true
        self.bigPlayBut.isHidden = true
        SDSPlayManager.share.play(player: player)
        //        if self.player.currentItem!.status == .readyToPlay {
        //            player.play()
        //        }else{
        //            NJLog("播放器尚未准备好播放")
        //        }
        
    }
    func pasuse(){//暂停
        pasueBut.isSelected = false
        self.bigPlayBut.isHidden = false
        if !isSetPlayerConfig {
            return
        }
        SDSPlayManager.share.pauseAll()
//        player.pause()
    }
    //快进播放
    @objc  func sliderValueDidChange(sender:UISlider){
        if !isSetPlayerConfig {
            self.play()
            return
        }
        if player.status == .readyToPlay {
            let time:Float64 = Float64(sender.value)*CMTimeGetSeconds(player.currentItem!.duration)
            if time.isNaN {
                return
            }
//            self.playLab.snp.remakeConstraints { (make) in
//                make.left.centerY.equalToSuperview()
//                make.width.equalToSuperview().multipliedBy(sender.value)
//                make.height.equalTo(sliderH)
//            }
            let seekTime = CMTimeMake(value: Int64(time), timescale: 1)
            player.seek(to: seekTime)
        }
    }
    @objc func  playToEndTime(){
        NJLog("播放完成")
        isFinished = true
        self.pasuse()
    }
    @objc func toolsShow(){
        if !isCanHideTools {
            return
        }
        
        UIView.animate(withDuration: 1) { [weak self] in
            if self!.isToolHide{
                self!.toolsView.isHidden = false
//                self!.toolsView.transform.translatedBy(x: -self!.toolH, y: 0)
                if  let block =  self?.showOrHideToolsBlock{
                    block(false)
                }
                
            }
            
        }
        hideTools()
    }
    func hideTools(){
        if !isCanHideTools {
            return
        }
        Timer.scheduledTimer(withTimeInterval: 8, repeats: false) { [weak self]_ in
            self?.MyHide()
        }
//        self.perform(#selector(MyHide), with: nil, afterDelay: 8)
//        self.perform(block: {[weak self] in
//            if self == nil || self?.toolsView == nil {
//                return
//            }
//            self?.toolsView.isHidden = true
////            self!.toolsView.transform.translatedBy(x: 0, y: self!.toolH)
//            self?.isToolHide = true
//            if  let block =  self?.showOrHideToolsBlock{
//                block(true)
//            }
//        }, timel: 8)


    }
    @objc func MyHide(){
        self.toolsView.isHidden = true
//            self!.toolsView.transform.translatedBy(x: 0, y: self!.toolH)
        self.isToolHide = true
        if  let block =  self.showOrHideToolsBlock{
            block(true)
        }
    }
}

//MARK: -视频观察者

extension SDSAVView {
    //KVO观察
    override  func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status"{
            switch self.player.currentItem!.status {
            case .readyToPlay:
//                self.play()
                break
            case .failed:
                NJLog("播放器获取资源失败")
            case .unknown :
                NJLog("播放获取资源发生未知错误")
                
            @unknown default:
                break
            }
        }else if keyPath == "loadedTimeRanges"{
            let loadTimeArray = self.player.currentItem!.loadedTimeRanges
            //获取最新缓存的区间
            let newTimeRange : CMTimeRange = loadTimeArray.first?.timeRangeValue ?? CMTimeRange.zero
            let startSeconds = CMTimeGetSeconds(newTimeRange.start);
            let durationSeconds = CMTimeGetSeconds(newTimeRange.duration);
            let totalBuffer = startSeconds + durationSeconds;//缓冲总长度
            let total = CMTimeGetSeconds(self.player.currentItem!.duration);
//            NJLog("缓存 \(totalBuffer)->\(total)")
            if totalBuffer.isNaN || total.isNaN {
                return
            }
            if  slider == nil {
                return
            }
//            if  bufferTimeLabel == nil {
//                return
//            }
//            bufferTimeLabel.snp.remakeConstraints { (make) in
//
//                    make.left.centerY.equalToSuperview()
//                    make.width.equalToSuperview().multipliedBy(totalBuffer / total)
//                    make.height.equalTo(sliderH)
//            }
            //            bufferTimeLabel.snp.updateConstraints{ (make) in
            //                make.width.equalToSuperview().multipliedBy(totalBuffer / total)
            //            }
            //            print("当前缓冲时间：%f",totalBuffer)
        }else if keyPath == "playbackBufferEmpty"{
            NJLog("正在缓存视频请稍等")
        }
        else if keyPath == "playbackLikelyToKeepUp"{
//            NJLog("缓存好了继续播放")
//            self.play()
        }
        
    }
    
}


extension SDSAVView {
    fileprivate func enterFullScreen() {
        if self.originParentView == nil {
            self.originParentView = self.superview
        }

        if self.orginFrame == nil {
//            setNeedsLayout()
//            setNeedsUpdateConstraints()
            layoutIfNeeded()
            updateConstraintsIfNeeded()
            self.orginFrame = self.frame
        }
//        NotificationCenter.default.post(UIApplication.didChangeStatusBarOrientationNotification)
        kAppdelegate.blockRotation = .landscapeRight
        self.fullParentView?.addSubview(self)
        self.fullParentView?.bringSubviewToFront(self)
        self.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }

    }
    fileprivate func exitFullScreen() {
        let orientation = UIApplication.shared.statusBarOrientation
        switch orientation {
        case .landscapeLeft, .landscapeRight:
            kAppdelegate.blockRotation = .portrait
        default:
            kAppdelegate.blockRotation = .portraitUpsideDown
        }
//        kAppdelegate.blockRotation = .portrait
        self.originParentView!.addSubview(self)
        self.snp.remakeConstraints { (make) in
            make.left.equalToSuperview().offset(orginFrame!.origin.x)
            make.top.equalToSuperview().offset(orginFrame!.origin.y)
            make.size.equalTo(orginFrame!.size)
        }

    }
}

