//
//  Extension+UIImageView.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 7/24/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import UIKit
import SwiftyGif

let imageCache = NSCache<AnyObject, AnyObject>()
extension UIImageView {

    func loadImageUsingCacheWithUrlString(urlString:String) {
        let stringClass = NSString(string: urlString)

        if let cachedImage = imageCache.object(forKey: stringClass) as? UIImage {
            self.image = cachedImage
            return
        }

        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error?.localizedDescription)
                return
            }

                 DispatchQueue.main.async {
                    if let downloadedImage = UIImage(data: data!) {
                        imageCache.setObject(downloadedImage, forKey: NSString(string: urlString))
                        self.image = downloadedImage
                    }
             }
        }.resume()



    }
//    func setGifTo(gifTitle:String) {
//        FirebaseController.instance.downloadGif(gifName: gifTitle) { (data) in
//            do {
//                let gif = try UIImage(gifData:data)
//                self.setGifImage(gif)
//            }
//            catch {
//                print(error)
//            }
//        }
//    }
}
