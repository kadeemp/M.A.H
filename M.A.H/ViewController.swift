//
//  ViewController.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 6/27/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import Firebase

import UIKit
import SwiftyGif

class ViewController: UIViewController {



    @IBOutlet var image1: UIImageView!
    @IBOutlet var image2: UIImageView!
    @IBOutlet var image3: UIImageView!
    @IBOutlet var image4: UIImageView!



    override func viewDidLoad() {
        super.viewDidLoad()
image1.setGifTo(gifTitle: "STOP IT MICHAEL JORDAN.gif")

let images = [image1,image2, image3, image4]

        FirebaseController.instance.loadGifsStringsWithCompletion { (strings) in
            do {
                var counter = 0
                if strings.count > 0 {
                    for image in images {
                        print(image!)
                        print(strings[counter])
                        image?.setGifTo(gifTitle: strings[counter])
                        counter += 1
                    }

                }
                else {
                    print(strings)
                    print("\n")
                    print("no strings loaded")
                }

            }
            catch {
                print(error)
            }
        }


// FirebaseController.instance.uploadGifs()
//       FirebaseController.instance.downloadImage(imageName: "HTPHarold.png") { (image)  in
//            let newImage = UIImageView(image: image)
//            newImage.frame.origin = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY)
//            self.view.addSubview(newImage)
//        }

    }

}


