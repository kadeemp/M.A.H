//
//  FirebaseController.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 7/20/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import Foundation
import Firebase


let DB_BASE = Database.database().reference()


class FirebaseController {

    static let instance = FirebaseController()

    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_SESSIONS = DB_BASE.child("sessions")


    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }

    var REF_USERS:DatabaseReference {
        return _REF_USERS
    }

    var REF_SESSIONS:DatabaseReference {
        return _REF_SESSIONS
    }

    func createDBUser(uid:String, userData:Dictionary<String,Any>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
}
