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
    lazy var container:UIView = {

        var view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 300))
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 20
        return view
    }()
    lazy var promptLabel:UILabel = {
        var label = UILabel(frame: CGRect(x: 10, y: 20, width: self.container.frame.width - 10, height: 80))

        //label.backgroundColor = UIColor.green
        label.text = "Kadeem wins the game!"
        label.textColor = UIColor.black
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 4

        return label
    }()

    lazy var newGameButton:UIButton = {
        //TODO:- CHANGE TO PROGRAMMATIC CONSTRAINTS
        var btn = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        print(btn.frame.origin)
        btn.center = CGPoint(x: self.container.frame.midX, y: self.container.frame.maxY - 80)
        btn.setTitle("New Game", for: .normal)
        btn.layer.backgroundColor = UIColor(red: 21/255, green: 209/255, blue: 200/255, alpha: 1).cgColor
        btn.layer.cornerRadius = 10

        return btn
    }()

    lazy var returntoLobby:UIButton = {
        //TODO:- CHANGE TO PROGRAMMATIC CONSTRAINTS
        var btn = UIButton(frame: CGRect(x: self.container.frame.midX, y: 0, width: 150, height: 40))
        btn.setTitle("Return to Lobby", for: .normal)

        btn.layer.backgroundColor = UIColor.red.cgColor
        btn.layer.cornerRadius = 10
        btn.center = CGPoint(x: self.container.frame.midX, y: self.container.frame.maxY - 30)
         print(btn.frame.origin)

        return btn
    }()

    //common func to init our view
    private func setupView() {

        backgroundColor = .white
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1

        container.addSubview(promptLabel)
        container.addSubview(returntoLobby)
        container.addSubview(newGameButton)
        self.addSubview(container)
    }
}
