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
    
    func hideLabelWithAnimation(_ andClear:Bool?){
        DispatchQueue.main.async {
            
            UIView.animate(withDuration: 0.5, delay: 0, animations: {
                self.layer.opacity = 0
            }) { (completed) in
                if let andClear = andClear {
                    if andClear {
                        self.clearPrompt()
                    }
                }
            }
        }
    }
        func clearPrompt() {
            self.text = ""
        }
        
        func showLabelWithanimation() {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 1) {
                    self.layer.opacity = 1
                }
            }
        }
        
        func updatePromptLabel(prompt:String) {
            UIView.animate(withDuration: 0.5, delay: 0, animations: {
                self.layer.opacity = 0
                
            }) { (completed) in
                self.text = prompt
                UIView.animate(withDuration: 1, delay: 0, animations: {
                    self.layer.opacity = 1
                    
                }, completion: nil)
                
            }
        }
        
    }
