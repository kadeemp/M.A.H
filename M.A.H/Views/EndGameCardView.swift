//
//  EndGameCard.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 12/18/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import UIKit

class EndGameCardView: UIView {

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

    lazy var newGameButton:UIButton = {
        //TODO:- CHANGE TO PROGRAMMATIC CONSTRAINTS
        var btn = UIButton(frame: CGRect(x: 50, y: 240, width: 100, height: 40))
        btn.setTitle("New Game", for: .normal)
        btn.layer.backgroundColor = UIColor(red: 21/255, green: 209/255, blue: 200/255, alpha: 1).cgColor
        btn.layer.cornerRadius = 10

        return btn
    }()



    lazy var returntoLobby:UIButton = {
        //TODO:- CHANGE TO PROGRAMMATIC CONSTRAINTS
        var btn = UIButton(frame: CGRect(x: 150, y: 240, width: 100, height: 40))
        btn.setTitle("Return to Lobby", for: .normal)
        btn.layer.backgroundColor = UIColor.red.cgColor
        btn.layer.cornerRadius = 10


        return btn
    }()


    //common func to init our view
    private func setupView() {
        self.layer.cornerRadius = 15
        backgroundColor = .white
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
        self.addSubview(promptLabel)
        self.addSubview(returntoLobby)
        self.addSubview(newGameButton)
        let deadline = DispatchTime.now() + 5
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.removeFromSuperview()
        }
    }
}

