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
    let id:String
    let members:[String]
    let code:String

    init(host:String, id:String, code:String, members:[String] ) {
        self.host = host
        self.id = id
        self.members = members
        self.code = code
    }
}
