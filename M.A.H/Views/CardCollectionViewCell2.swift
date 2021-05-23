//
//  CardCollectionViewCell2.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 1/31/20.
//  Copyright © 2020 Kadeem Palacios. All rights reserved.
//
import AVKit
import UIKit

class CardCollectionViewCell2: UICollectionViewCell {
    
    @IBOutlet var videoDisplayView: UIView!
    var avPlayerLayer: AVPlayerLayer!

    override func awakeFromNib() {

    }

    func setupPlayer(urlString:String) {
        let url = URL(string: urlString)

        let player = AVPlayer(url: url!)
        avPlayerLayer = AVPlayerLayer(player: player)
        avPlayerLayer.frame = self.bounds
//        print("current layer count is\(videoDisplayView.layer.sublayers!.count)")
        if videoDisplayView.layer.sublayers == nil {
        videoDisplayView.layer.addSublayer(avPlayerLayer)
        } else if  videoDisplayView.layer.sublayers!.count == 1 {
            videoDisplayView.layer.replaceSublayer(videoDisplayView.layer.sublayers![0], with: avPlayerLayer )
        }

        //print("current layer count after is\(videoDisplayView.layer.sublayers!.count)")
        player.play()

        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { (notification) in
            player.seek(to: CMTime.zero)
            player.play()
        }

    }
}
