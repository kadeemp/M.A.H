//
//  Extenion + UILabel.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 1/28/20.
//  Copyright © 2020 Kadeem Palacios. All rights reserved.
//

import Foundation
import  UIKit

extension UILabel {

    func hideLabelWithAnimation(){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1) {
                self.layer.opacity = 0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.text = ""
        }
    }

    func showLabelWithanimation() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1) {
                self.layer.opacity = 1
            }
        }
    }

    func resetLabel() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1) {
                self.layer.opacity = 0
            }
        }
        self.text = ""
    }
}
