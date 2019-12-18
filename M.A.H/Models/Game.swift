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
    let table:[String:[String:Any]]?
    var state:Int

    init(key:String, round:Int, table:[String:[String:Any]]?, state:Int) {
        self.key = key
        self.round = round
        self.table = table
        self.state = state
    }
    
}
