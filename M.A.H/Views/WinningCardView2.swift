//
//  WinningCardView2.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 1/31/20.
//  Copyright © 2020 Kadeem Palacios. All rights reserved.
//


import UIKit
import AVKit

class WinningCardView2: UIView {

    //initWithFrame to init view from code
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    //initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    lazy var promptLabel:UILabel = {
        var label = UILabel(frame: CGRect(x: 20, y: 20, width: 160, height: 80))

        //label.backgroundColor = UIColor.green
        label.text = "Kadeem Wins!!"
        label.textColor = UIColor.black
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 4

        return label
    }()


var avPlayerLayer: AVPlayerLayer!
    lazy var gifImage:UIView = {
        //TODO:- CHANGE TO PROGRAMMATIC CONSTRAINTS
        let View = UIView(frame: CGRect(x:20, y: 80 , width: 160, height: 100))
        //imageView.frame.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        return View
    }()
    //TODO:- refactor so that this func doesn't have to e rewritten
        func setupPlayer(urlString:String) {
            let url = URL(string: urlString)

            let player = AVPlayer(url: url!)
            avPlayerLayer = AVPlayerLayer(player: player)
            avPlayerLayer.frame = gifImage.bounds
            gifImage.layer.addSublayer(avPlayerLayer)


            player.play()

            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { (notification) in
                player.seek(to: CMTime.zero)
                player.play()
            }

        }



    lazy var dismissButton:UIButton = {
        //TODO:- CHANGE TO PROGRAMMATIC CONSTRAINTS
        var btn = UIButton(frame: CGRect(x: 50, y: 240, width: 100, height: 40))
        btn.setTitle("Dismiss", for: .normal)
        btn.layer.backgroundColor = UIColor.red.cgColor
        btn.layer.cornerRadius = 10
        btn.addTarget(self, action: #selector(dismissBtn), for: .touchUpInside)

        return btn
    }()
    @objc func dismissBtn() {
        //TODO:- ADD BUTTON SWAP ANIMATION
        self.removeFromSuperview()
    }

    //common func to init our view
    private func setupView() {
        self.layer.cornerRadius = 15
        backgroundColor = .white
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
        self.addSubview(promptLabel)
        self.addSubview(gifImage)
        let deadline = DispatchTime.now() + 5
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.removeFromSuperview()
        }
    }
}

