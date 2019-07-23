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

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! NewCollectionViewCell
        return cell
    }

    @IBOutlet var cView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
      //  var i = UIImageView(image: UIImage())
        var v = UIImageView()
        v.frame = CGRect(x: 50, y: 50, width: 100, height: 100)
        v.layer.backgroundColor = UIColor.red.cgColor
        self.view.addSubview(v)
        
        FirebaseController.instance.downloadGif(gifName: "STOP IT MICHAEL JORDAN.gif") { (data) in
            do {
                let gif = try UIImage(gifData:data)
                let gifView = UIImageView(gifImage: gif)
                gifView.frame.origin = CGPoint(x: 0, y: 0)
                gifView.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
                gifView.layer.backgroundColor = UIColor.blue.cgColor
                gifView.startAnimating()
                print(gifView)
                print(gif)
                print(self.view.subviews.count)
                self.view.addSubview(gifView)
                print(self.view.subviews.count)
            }
            catch {
                print(error)
            }
        }


//        FirebaseController.instance.loadGifsStringsWithCompletion { (strings) in
//            do {
//                if strings.count > 0 {
//
//                    let gif = try UIImage(gifData:  FirebaseController.instance.returnGif(gifName: strings[0])!)
//
//                }
//                else {
//                    print(strings)
//                    print("\n")
//                    print("no strings loaded")
//                }
//
//            }
//            catch {
//                print(error)
//            }
//        }







// FirebaseController.instance.uploadGifs()
//       FirebaseController.instance.downloadImage(imageName: "HTPHarold.png") { (image)  in
//            let newImage = UIImageView(image: image)
//            newImage.frame.origin = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY)
//            self.view.addSubview(newImage)
//        }

    }

}

