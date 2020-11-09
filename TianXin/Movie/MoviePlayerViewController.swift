//
//  MoviePlayerViewController.swift
//  TianXin
//
//  Created by pretty on 10/12/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import AVFoundation
import RxCocoa
import RxSwift
import RxGesture

class MoviePlayerViewController: UIViewController {
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var volumeButton: UIButton!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var titleViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    
    fileprivate var timer: Timer?
    fileprivate var disposable: Disposable?
    
    // 多少秒后头部title和底部菜单消失
    var durationOfBar = 5
    
    var sdsPlayerController: SDSPlayerVC? {
        return children.first { $0 is SDSPlayerVC } as? SDSPlayerVC
    }
    
    
    var player: TinyPlayerLayerView?
    
    
    var movie: TopicMovie? {
        didSet {
            setupUI()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        trackEvents()
    }
    
    private func makeUI() {
        titleViewHeightConstraint.constant = KnavHeight
        self.view.layoutIfNeeded()
        slider.setThumbImage(R.image.icon_progressBar(), for: .normal)
        slider.setThumbImage(R.image.icon_progressBar(), for: .highlighted)
    }
    // 配置UI数据
    private func setupUI() {
        setupSDSPlayer()
        titleLabel.text = movie?.title
        // 配置SDSPlayerVC
    }
    // 配置UI事件
    private func trackEvents() {
        // 点击返回按钮
        backButton.rx.tap
            .asObservable()
            .subscribe(onNext: {[weak self] in
                if let vc = self?.navigationController?.viewControllers.first(where: {$0 is MovieListOnTopicViewController}) {
                    self?.navigationController?.popToViewController(vc, animated: true)
                } else {
                    self?.navigationController?.popViewController(animated: true)
                }
                
            })
            .disposed(by: rx.disposeBag)
        // 点击播放按钮
        playButton.rx.tap
            .asObservable()
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.playButton.isSelected.toggle()
                if self.playButton.isSelected {
                    self.play()
                } else {
                    self.pause()
                }
            })
            .disposed(by: rx.disposeBag)
        // 操作滑动栏
        slider.rx.value.changed
            .asObservable()
            .subscribe(onNext: { [weak self] progress in
                self?.seek(to: progress)
            })
            .disposed(by: rx.disposeBag)
        // 点击音量按钮
        volumeButton.rx.tap
            .asObservable()
            .subscribe(onNext: {[weak self] in
                self?.volumeButton.isSelected.toggle()
                self?.operateVolume()
            })
            .disposed(by: rx.disposeBag)
        // 点击全屏按钮
        fullScreenButton.rx.tap
            .asObservable()
            .subscribe(onNext: {[weak self] in
                self?.fullScreenButton.isSelected.toggle()
            })
            .disposed(by: rx.disposeBag)
        // 添加点击播放屏幕手势
        self.view.rx.tapGesture().asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.showBar()
            })
            .disposed(by: rx.disposeBag)
    }
    // 播放
    func play() {
        startTimer()
    }
    // 暂停
    func pause() {
        showBar()
        sdsPlayerController?.pasuse()
    }
    // seek
    func seek(to progress: Float) {
        
    }
    // 静音或打开音放
    func operateVolume() {
        if volumeButton.isSelected {
            
        } else {
            
        }
    }
    //全屏显示
    func enterFullScreen() {
        
    }
    // 退出显示
    func exitFullScreen() {
        
    }
    
    // 显示顶部和底部
    func showBar() {
        titleViewTopConstraint.constant = 0
        bottomViewBottomConstraint.constant = 0
        
        UIView.animate(withDuration: 0.25) {
            self.titleView.alpha = 1
            self.view.layoutIfNeeded()
        }
        startTimer()
    }
    // 隐藏顶部和底部
    func hideBar() {
        titleViewTopConstraint.constant = -KnavHeight
        bottomViewBottomConstraint.constant = -44
        UIView.animate(withDuration: 0.25) {
            self.titleView.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func startTimer() {
        self.disposable?.dispose()
        // 3s中之后hide accessory views
        self.disposable = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                guard let self = self else {
                    return
                }
                if state == self.durationOfBar {
                    self.hideBar()
                    self.disposable?.dispose()
                }
            })
    }
    
    deinit {
        print("\(self) deinit")
        self.disposable?.dispose()
    }
}


extension MoviePlayerViewController {
    func setupSDSPlayer() {
        sdsPlayerController?.url = try? movie?.address?.asURL()
        sdsPlayerController?.coverImgUrl = movie?.cover ?? ""
    }
}
