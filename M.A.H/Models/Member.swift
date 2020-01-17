//
//  Member.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 1/17/20.
//  Copyright © 2020 Kadeem Palacios. All rights reserved.
//

import Foundation
struct Member {

    let name:String
    let profileURL:String
    let moderatorStatus:Bool
    var score:Int

    init(name:String, profileURL:String,moderatorStatus:Bool, score:Int) {
        self.name = name
        self.profileURL = profileURL
        self.moderatorStatus = moderatorStatus
        self.score = score
    }

}
