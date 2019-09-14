//
//  Extention + String.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 9/4/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import Foundation

extension String {

    func stripID() -> String {
        var strippped = Array(self)
        var inc = 0
        for i in 0..<strippped.count - 1 {

            if strippped[i - inc] == "-" {
                strippped.remove(at: i - inc)
                inc = inc + 1

            } else if strippped[i - inc] == "_" {
                strippped.remove(at: i - inc)
                inc = inc + 1
            }
        }
        return String(strippped)
    }
}
