//
//  ResponseCard.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 9/10/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import Foundation

struct ResponseCard {
    let cardKey:String
    let fileName:String
    let playedBy:String?
    let isRevealed:Bool

    init(cardKey:String, fileName:String, /*fileType:String,*/ playedBy:String?, /*cardType:String,*/ isRevealed:Bool) {
        self.cardKey = cardKey
        self.fileName = fileName
        self.playedBy = playedBy
        self.isRevealed = isRevealed

    }
}
