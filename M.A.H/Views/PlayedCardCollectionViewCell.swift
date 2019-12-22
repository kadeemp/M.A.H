//
//  PlayedCardCollectionViewCell.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 11/7/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import UIKit

class PlayedCardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageHolderView: UIView!
    @IBOutlet var cardImageView: UIImageView!
    @IBOutlet var revealedCardImageView: UIImageView!

    var response:MemeCard!
    func loadImage() {
        FirebaseController.instance.downloadGif(gifName: response.fileName) { (data) in
            do {
                let gif = try UIImage(gifData:data)
                let gifView = UIImageView(gifImage: gif)
                gifView.frame.origin = CGPoint(x: 0, y: 0)
                gifView.frame = CGRect(x:0, y:0, width: 100, height: 100)
                self.revealedCardImageView.setGifImage(gif)
            }
            catch {
                print(error)
            }

        }
    }
    override func awakeFromNib() {
    }

}
