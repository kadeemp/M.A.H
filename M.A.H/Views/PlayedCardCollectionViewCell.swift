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
    var card:MemeCard!
    var key:String!

    override func awakeFromNib() {
        imageHolderView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardRevealTranstition)))
    }
    
   @objc func cardRevealTranstition() {
    UIView.transition(from: cardImageView, to: revealedCardImageView, duration: 1, options: .transitionFlipFromLeft, completion: nil)
    if card != nil && key != nil {
        FirebaseController.instance.revealResponse(gameKey: key, card: card)
    } else {
        print("Card data hasn't been passed")
    }
    }
}
