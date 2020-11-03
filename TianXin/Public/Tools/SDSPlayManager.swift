//
//  SDSPlayManager.swift
//  TianXin
//
//  Created by SDS on 2020/10/23.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import AVFoundation
class SDSPlayManager: NSObject {
  static var share  =  SDSPlayManager()
   private var playArrS:[AVPlayer] = [AVPlayer]()
    func play(player:AVPlayer){
        playArrS.forEach { (player) in
            player.pause()
        }
        if !playArrS.contains(player) {
            playArrS.append(player)
        }
        player.play()
        
    }
    func  pauseAll() {
        playArrS.forEach { (player) in
            player.pause()
        }
    }
    func pause(player:AVPlayer) {
        if playArrS.contains(player) {
            player.pause()
        }
    }
    func remove(player:AVPlayer) {
        if let index = playArrS.firstIndex(of: player) {
            playArrS.remove(at: index)
        }
       
    }
    func printPlayerCount() {
        NJLog("剩余视频播放器的数量：\(playArrS.count)")
    }
//    ///从头开始播放
//    func rePlay(player:AVPlayer)  {
//        playArrS.forEach { (player) in
//            player.pause()
//        }
//        if !playArrS.contains(player) {
//            playArrS.append(player)
//        }
//        player.seek(to: CMTime.zero)
//    }
}
