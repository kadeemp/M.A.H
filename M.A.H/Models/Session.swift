//
//  Session.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 7/26/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import Foundation

struct Session {
    var host:String
    var hostID:String
    var members:[String:[String:Any]]
    var code:String
    var key:String
    var gameID:String?
    var moderator:[String:String]?
    var isActive:Bool

    init(host:String, hostID:String, code:String, members:[String:[String:Any]], key:String, gameID:String?, isActive:Bool) {
        self.host = host
        self.hostID = hostID
        self.members = members
        self.code = code
        self.key = key
        self.gameID = gameID
        self.isActive = isActive
    }
}
