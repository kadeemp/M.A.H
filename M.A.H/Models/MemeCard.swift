//
//  Card.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 8/9/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import Foundation

struct MemeCard:Equatable {
    let cardKey:String
    let fileName:String
    let fileType:String
    var playedBy:String?
    let cardType:String
    var isRevealed:Bool

    init(cardKey:String, fileName:String, fileType:String, playedBy:String?, cardType:String, isRevealed:Bool) {
        self.cardKey = cardKey
        self.fileName = fileName
        self.fileType = fileType
        self.playedBy = playedBy
        self.cardType = cardType
        self.isRevealed = isRevealed

    }
}
