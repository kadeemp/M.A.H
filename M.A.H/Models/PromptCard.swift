//
//  PromptCard.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 8/12/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//


import Foundation

struct PromptCard {
    let cardKey:String
    let prompt:String
    let playedBy:String?
    let isRevealed:Bool

    init(cardKey:String, prompt:String,playedBy:String?, isRevealed:Bool) {
        self.cardKey = cardKey
        self.prompt = prompt
        self.playedBy = playedBy
        self.isRevealed = isRevealed

    }

}
