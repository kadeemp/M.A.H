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
    let members:[String]
    let code:String
    let key:String
    let gameID:String?

    init(host:String, id:String, code:String, members:[String], key:String, gameID:String? ) {
        self.host = host
        self.hostID = id
        self.members = members
        self.code = code
        self.key = key
        self.gameID = gameID
    }
}
