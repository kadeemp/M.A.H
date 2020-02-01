//
//  PlayedCardCollectionViewCell.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 11/7/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import UIKit
import AVKit

class PlayedCardCollectionViewCell2: UICollectionViewCell {


    @IBOutlet var imageHolderView: UIView!
    @IBOutlet var cardImageView: UIImageView!
    @IBOutlet var revealedCardImageView: UIView!
    var avPlayerLayer: AVPlayerLayer!

    override func awakeFromNib() {
    }
        func setupPlayer(urlString:String) {
            let url = URL(string: urlString)

            let player = AVPlayer(url: url!)
            avPlayerLayer = AVPlayerLayer(player: player)
            avPlayerLayer.frame = self.bounds

            if revealedCardImageView.layer.sublayers == nil {
            revealedCardImageView.layer.addSublayer(avPlayerLayer)
            } else if  revealedCardImageView.layer.sublayers!.count == 1 {
                revealedCardImageView.layer.replaceSublayer(revealedCardImageView.layer.sublayers![0], with: avPlayerLayer )
            }

            print("current layer count after is\(revealedCardImageView.layer.sublayers!.count)")
            player.play()

            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { (notification) in
                player.seek(to: CMTime.zero)
                player.play()
            }
        }
}
