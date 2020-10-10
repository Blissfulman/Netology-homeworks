//
//  PhotoCollectionViewCell.swift
//  Course2FinalTask
//
//  Created by User on 07.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation
import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "photoCell"
    
    @IBOutlet weak var photoImage: UIImageView!
    
    static func nib() -> UINib {
        return UINib(nibName: "ProfileCollectionViewCell", bundle: nil)
    }
    
    func configure(_ photo: UIImage) {
        photoImage.image = photo
    }
}
