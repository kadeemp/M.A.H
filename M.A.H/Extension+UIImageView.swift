//
//  Extension+UIImageView.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 7/24/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import UIKit

extension UIImageView {
    func setGifTo(gifTitle:String) {
        FirebaseController.instance.downloadGif(gifName: gifTitle) { (data) in
            do {
                let gif = try UIImage(gifData:data)
                self.setGifImage(gif)
            }
            catch {
                print(error)
            }
        }
    }
}
