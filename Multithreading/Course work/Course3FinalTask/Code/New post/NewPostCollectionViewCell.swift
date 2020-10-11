//
//  NewPostCollectionViewCell.swift
//  Course3FinalTask
//
//  Created by User on 03.10.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation
import UIKit

class NewPostCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImage: UIImageView!
    
    func configure(_ photo: UIImage) {
        photoImage.image = photo
    }
}
