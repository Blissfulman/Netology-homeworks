//
//  FiltersCollectionViewCell.swift
//  Course3FinalTask
//
//  Created by User on 04.10.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

class FiltersCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var exampleImage: UIImageView!
    @IBOutlet weak var filterNameLabel: UILabel!
    
    func configure(photo: UIImage, filterName: String) {
        exampleImage.image = photo
        filterNameLabel.text = filterName
    }

}
