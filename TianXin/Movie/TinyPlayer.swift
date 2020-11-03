//
//  TinyPlayer.swift
//  TianXin
//
//  Created by pretty on 10/12/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa


protocol TinyPlayerLayerViewDelegate: NSObjectProtocol {
    func tinyPlayer(_ player: TinyPlayerLayerView, playerStateDidChange state: TinyPlayerLayerView.TinyPlayerState)
    func tinyPlayer(_ player: TinyPlayerLayerView, loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval)
    func tinyPlayer(player: TinyPlayerLayerView, playTimeDidChange currentTime: TimeInterval, totalTime: TimeInterval)
}

class TinyPlayerLayerView: UIView {
    // 跳转播放时间
    var seekTime = 0 as TimeInterval
    var playerItem: AVPlayerItem? {
        didSet {
            guard let item = oldValue else {
                return
            }
            configurePlayerItem(newPlayerItem: item)
        }
    }
    weak var delegate: TinyPlayerLayerViewDelegate?
    var isPlaying: Bool = false
    
    lazy var player: AVPlayer? = {
        guard let item = self.playerItem else {
            return nil
        }
        return AVPlayer(playerItem: item)
    }()
    // 播放完毕
    var playDidEnd: Bool {
        return state == .playedToTheEnd
    }
    fileprivate var state: TinyPlayerState = .noAsset {
        didSet {
            if state != oldValue {
                
            }
        }
    }
    //
    fileprivate var lastPlayerItem: AVPlayerItem?
    fileprivate var urlAssert: AVURLAsset?
    
    func play(url: URL) {
        let asset = AVURLAsset(url: url)
        play(asset: asset)
    }
    func play(asset: AVURLAsset) {
        urlAssert = asset
        
    }
    func play() {
        guard let player = self.player else { return }
        player.play()
        isPlaying = true
    }
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    // setup player item
    func configurePlayerItem(newPlayerItem: AVPlayerItem) {
        if lastPlayerItem == newPlayerItem { return }
        // 移除对上个播放资源的观察
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: lastPlayerItem)
        lastPlayerItem?.removeObserver(self, forKeyPath: PlayerItemObserverKey.status.rawValue)
        lastPlayerItem?.removeObserver(self, forKeyPath: PlayerItemObserverKey.loadedTimeRanges.rawValue)
        lastPlayerItem?.removeObserver(self, forKeyPath: PlayerItemObserverKey.playbackBufferEmpty.rawValue)
        lastPlayerItem?.removeObserver(self, forKeyPath: PlayerItemObserverKey.playbackLikelyToKeepUp.rawValue)
        
        lastPlayerItem = newPlayerItem
        NotificationCenter.default.rx.notification(.AVPlayerItemDidPlayToEndTime, object: newPlayerItem)
            .subscribe(onNext: { [weak self] notification in
                guard let self = self else { return }
                if self.state == .playedToTheEnd { return }
                if let playerItem = self.playerItem {
                    self.delegate?.tinyPlayer(player: self, playTimeDidChange: CMTimeGetSeconds(playerItem.duration), totalTime: CMTimeGetSeconds(playerItem.duration))
                }
                self.state = .playedToTheEnd
                
            })
            .disposed(by: rx.disposeBag)
        // 监听视频播放状态
        observeStatus(for: newPlayerItem)
        // 监听 loadedTimeRanges
        observeLoadedTimeRanges(for: newPlayerItem)
        // playbackBufferEmpty
        observePlaybackBufferEmpty(for: newPlayerItem)
        // playbackLikelyToKeepUp
        observePlaybackLikelyToKeepUp(for: newPlayerItem)
    }
    
}

// observe properties
extension TinyPlayerLayerView {
    fileprivate func observeStatus(for item: AVPlayerItem) {
        item.rx.observeWeakly(AVPlayerItem.Status.self, "status", options: .new)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] status in
                guard let self = self else { return }
                // 如果播放资源出现错误
                if case .failed = status {
                    self.state = .error
                    return
                }
                // 如果播放器出现错误
                if case .failed = self.player?.status {
                    self.state = .error
                    return
                }
                // 准备播放
                if case .readyToPlay = self.player?.status {
                    self.state = .buffering
                    if self.seekTime != 0 {
                        self.seek(to: self.seekTime)
                            .subscribe(onNext: { shouldToSeek in
                                
                            })
                            .disposed(by: self.rx.disposeBag)
                    } else {
                        self.state = .readyToPlay
                    }
                }
            })
            .disposed(by: rx.disposeBag)
    }
    fileprivate func observeLoadedTimeRanges(for item: AVPlayerItem) {
        
    }
    fileprivate func observePlaybackBufferEmpty(for item: AVPlayerItem) {
        
    }
    fileprivate func observePlaybackLikelyToKeepUp(for item: AVPlayerItem) {
        
    }
}

extension TinyPlayerLayerView {
    func seek(to seconds: TimeInterval) -> Observable<TimeInterval> {
        return Observable.create { [weak self] observer in
            if seconds.isNaN {
                observer.onError(NSError(domain: "seek to nan seconds", code: -1, userInfo: nil))
            }
            if case .readyToPlay = self?.player?.currentItem?.status {
                let draggedTime = CMTime(value: CMTimeValue(seconds), timescale: 1)
                self?.player?.seek(to: draggedTime, toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: { finished in
                    if finished {
                        observer.onCompleted()
                    }
                })
            } else {
                observer.onNext(seconds)
            }
            return Disposables.create()
        }
    }
}

extension TinyPlayerLayerView {
    enum PlayerItemObserverKey: String {
        // 资源播放状态
        case status
        // 缓冲进度
        case loadedTimeRanges
        // 跳转播放没数据,可选
        case playbackBufferEmpty
        // 跳转播放有数据，可选
        case playbackLikelyToKeepUp
    }
    enum TinyPlayerState {
        // 没有设置播放资源
        case noAsset
        // 准备播放
        case readyToPlay
        // 缓冲中
        case buffering
        // 缓冲结束
        case bufferFinished
        // 播放完毕
        case playedToTheEnd
        // 播放过程中出现错误
        case error
    }
}
