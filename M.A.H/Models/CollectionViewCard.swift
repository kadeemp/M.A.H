//
//  CollectionViewCard.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 9/8/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import Foundation

struct Card {
    let card:MemeCard
    let indexPath:IndexPath
    init(card:MemeCard, indexPath:IndexPath) {
        self.card = card
        self.indexPath = indexPath
    }
}
