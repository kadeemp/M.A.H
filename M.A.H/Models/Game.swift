//
//  Game.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 8/27/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import Foundation
struct Game {

    let key:String
    let round:Int
    let scoreboard:[String:[String:Any]]
    let table:[String:[String:Any]]?

    init(key:String, round:Int, scoreboard:[String:[String:Any]], table:[String:[String:Any]]?) {
        self.key = key
        self.round = round
        self.scoreboard = scoreboard
        self.table = table
    }
    
}
