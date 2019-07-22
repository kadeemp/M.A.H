//
//  ViewController.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 6/27/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import Firebase

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       FirebaseController.downloadImage(imageName: "HTPHarold.png") { (image)  in
            let newImage = UIImageView(image: image)
            newImage.frame.origin = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY)
            self.view.addSubview(newImage)
        }
        // Do any additional setup after loading the view.
    }




}

