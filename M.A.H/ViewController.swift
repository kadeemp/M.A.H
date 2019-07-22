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
        downloadImage(imageName: "HTPHarold.png") { (image)  in
            let newImage = UIImageView(image: image)
            newImage.frame.origin = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY)
            self.view.addSubview(newImage)
        }
        // Do any additional setup after loading the view.
    }

    func downloadImage(imageName:String, completion: @escaping ((UIImage) -> ()))  {
        let imageRef = "Meme folder/\(imageName)"
        let storage = Storage.storage()

        let haroldRef = storage.reference(withPath: imageRef)

        haroldRef.getData(maxSize: 1 * 1024 * 1024, completion: {(data, error) in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error)
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                completion(image!)
            }
        })
    }


}

