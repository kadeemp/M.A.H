//
//  WinningCardView.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 11/10/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import UIKit

class WinningCardView: UIView {

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

    lazy var revealButton:UIButton = {
        //TODO:- CHANGE TO PROGRAMMATIC CONSTRAINTS
        var btn = UIButton(frame: CGRect(x: 50, y: 240, width: 100, height: 40))
        btn.setTitle("Reveal", for: .normal)
        btn.layer.backgroundColor = UIColor(red: 21/255, green: 209/255, blue: 200/255, alpha: 1).cgColor
        btn.layer.cornerRadius = 10
        btn.addTarget(self, action: #selector(swapButtons), for: .touchUpInside)

        return btn
    }()
    lazy var gifImage:UIImageView = {
        //TODO:- CHANGE TO PROGRAMMATIC CONSTRAINTS
        let imageView = UIImageView(frame: CGRect(x:20, y: 80 , width: 160, height: 100))
        //imageView.frame.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)

        return imageView
    }()


    @objc func swapButtons() {

        revealButton.isUserInteractionEnabled = false

        //TODO:- ADD BUTTON SWAP ANIMATION
        revealButton.removeFromSuperview()
//ADD FIREBASE FUNC
        self.addSubview(dismissButton)
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
        self.addSubview(dismissButton)
        self.addSubview(gifImage)
    }
}
