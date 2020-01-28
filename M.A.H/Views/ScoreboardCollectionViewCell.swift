//
//  ScoreboardCollectionViewCell.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 1/17/20.
//  Copyright © 2020 Kadeem Palacios. All rights reserved.
//

import UIKit

class ScoreboardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var profilePhoto: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    override func awakeFromNib() {
        profilePhoto.clipsToBounds = true
        profilePhoto.layer.borderWidth = 2
        profilePhoto.layer.cornerRadius = profilePhoto.frame.height/2



    }
}
