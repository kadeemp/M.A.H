//
//  Extension + UIView.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 12/30/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import Foundation
import UIKit
extension UIView {
    func fadeViewIn() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 2) {
                self.layer.opacity = 1
            }
        }
    }

    func fadeViewOut() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 2) {
                self.layer.opacity = 0
            }
        }
    }


    
    

}
