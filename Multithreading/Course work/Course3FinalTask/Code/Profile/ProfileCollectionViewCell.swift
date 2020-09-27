//
//  PhotoCollectionViewCell.swift
//  Course2FinalTask
//
//  Created by User on 07.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation
import UIKit
import DataProvider

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImage: UIImageView!
    
    func configure(_ photo: UIImage) {
        photoImage.image = photo
    }
}
