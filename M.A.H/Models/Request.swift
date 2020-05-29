//
//  Request.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 5/25/20.
//  Copyright © 2020 Kadeem Palacios. All rights reserved.
//

class Request {
    private var _requestType: String
    private var _senderId: String
    private var _requestStatus:String


    var requestType: String {
        return _requestType
    }

    var senderId: String {
        return _senderId
    }
    var requestStatus:String {
        return _requestStatus
    }



    init(requestType: String, senderId: String, requestStatus:String) {
        self._requestType = requestType
        self._senderId = senderId
        self._requestStatus = requestStatus

    }
}
