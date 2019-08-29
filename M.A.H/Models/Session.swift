//
//  Session.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 7/26/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import Foundation

struct Session {
    let host:String
    let hostID:String
    let members:[String:String]
    let code:String
    let key:String
    let gameID:String?
    let state:Int
    let isActive:Bool

    init(host:String, hostID:String, code:String, members:[String:String], key:String, gameID:String? ,state:Int, isActive:Bool) {
        self.host = host
        self.hostID = hostID
        self.members = members
        self.code = code
        self.key = key
        self.gameID = gameID
        self.state = state
        self.isActive = isActive
    }
}
